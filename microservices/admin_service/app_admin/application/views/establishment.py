from drf_yasg.utils import swagger_auto_schema
from rest_framework.views import APIView
from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView, DestroyAPIView

from app_admin.adapters.serializer import EstablishmentListSerializer, EstablishmentCreateSerializer, \
    MessageTransactional, EstablishmentCreateResponseSerializer
from app_admin.utils.pagination import StandardResultsSetPagination
from app_admin.domain.service.establishment_service import EstablishmentService
from app_admin.adapters.impl.establishment_impl import EstablishmentRepositoryImpl
from app_admin.domain.service.law_enforcement_service import LawEnforcementService
from app_admin.adapters.impl.law_enforcement_impl import LawEnforcementImpl
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q

from app_admin.domain.service.access_information_service import AccessInformationService
from app_admin.adapters.impl.access_information_impl import AccessInformationImpl

from app_admin.adapters.impl.function_organization_impl import FunctionOrganizationImpl
from app_admin.adapters.impl.type_institution_impl import TypeInstitutionImpl
from app_admin.adapters.impl.type_organization_impl import TypeOrganizationImpl


class EstablishmentListAPI(ListAPIView):

    pagination_class = StandardResultsSetPagination
    serializer_class = EstablishmentListSerializer

    def __init__(self):
        """
        The constructor for the UserListAPI class.
        """
        self.user_service = EstablishmentService(EstablishmentRepositoryImpl())

    def get_queryset(self):
        """
        Get a list of users.

        Returns:
            User: The list of users.
        """
        return self.user_service.get_establishments()

    # search by username

    def get(self, request, *args, **kwargs):
        """
        Get a list of users.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        queryset = self.get_queryset()
        search = request.query_params.get('search', None)
        if search is not None:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(abbreviation__icontains=search))

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)


class EstablishmentCreateAPI(APIView):
    """
        Endpoint para crear Entidad.

        Args:
           EstablishmentCreateAPIView (_type_): The EstablishmentCreateAPIView class is a generic view
           that provides a list of objects.

        Returns:
            EstablishmentCreateAPI: An instance of the EstablishmentCreateAPI class.
    """
    serializer_class = EstablishmentCreateSerializer
    permission_classes = [IsAuthenticated]

    output_serializer_class = EstablishmentListSerializer

    def __init__(self):
        """
        The constructor for the EstablishmentCreateAPI class.
        """
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.access_info = AccessInformationService(AccessInformationImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())

    @swagger_auto_schema(
        operation_description="Create a establishment",
        response={
            201: output_serializer_class,
            400: MessageTransactional
        },
        request_body=serializer_class,
        # form data

    )
    def post(self, request, *args, **kwargs):
        """
        Create a establishment.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data = self.serializer_class(data=request.data)
        file = request.FILES['logo']
        data.is_valid(raise_exception=True)
        establishment = None
        law = None
        access = None
        try:
            establishment = self.establishment_service.create_establishment(
                data.data, file)
            access = self.access_info.create_access_information(data.data)
            law = self.law_enforcement.create_law_enforcement(data.data)
            self.access_info.assign_establishment_to_access_information(
                access.id, establishment)
            self.law_enforcement.assign_establishment_to_law_enforcement(
                law.id, establishment)
            res = MessageTransactional(
                data={
                    'message': 'Entidad creada correctamente',
                    'status': 201,
                    'json': self.output_serializer_class(establishment).data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:
            if establishment is not None:
                self.establishment_service.delete_establishment(
                    establishment.id)

            if access is not None:
                self.access_info.delete_access_information(access.id)

            if law is not None:
                self.law_enforcement.delete_law_enforcement(law.id)
            print("Error:", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class EstablishmentDetail(APIView):
    """
    Endpoint para obtener una entidad.

    Args:
       RetrieveAPIView (_type_): The RetrieveAPIView class is a generic view
       that provides a list of objects.

    Returns:
        EstablishmentDetail: An instance of the EstablishmentDetail class.
    """
    serializer_class = EstablishmentCreateResponseSerializer
    permission_classes = [IsAuthenticated]

    def __init__(self):
        """
        The constructor for the EstablishmentDetail class.
        """
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())

    def get(self, request, pk, *args, **kwargs):
        """
        Get a establishment.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """

        try:

            establishment = self.establishment_service.get_establishment(pk)
            info = self.establishment_service.get_first_access_to_information(
                pk)
            law_enforcement = self.law_enforcement.get_law_enforcement_by_establishment(
                pk)
            serializer = self.serializer_class(data={
                'id': establishment.id,
                'name': establishment.name,
                'abbreviation': establishment.abbreviation,
                'logo': establishment.logo.url if establishment.logo else None,
                'highest_authority': establishment.highest_authority,
                'first_name_authority': establishment.first_name_authority,
                'last_name_authority': establishment.last_name_authority,
                'job_authority': establishment.job_authority,
                'email_authority': establishment.email_authority,
                'highest_committe': law_enforcement.highest_committe if law_enforcement is not None else None,
                'first_name_committe': law_enforcement.first_name_committe if law_enforcement is not None else None,
                'last_name_committe': law_enforcement.last_name_committe if law_enforcement is not None else None,
                'job_committe': law_enforcement.job_committe if law_enforcement is not None else None,
                'email_committe': law_enforcement.email_committe if law_enforcement is not None else None,
                'email_accesstoinformation': info.email if info is not None else None,
                'address': establishment.address if establishment.address else '',
                'type_institution': establishment.type_institution.id if establishment.type_institution else None,
                'type_organization': establishment.type_organization.id if establishment.type_organization else None,
                'function_organization': establishment.function_organization.id if establishment.function_organization else None,
                'identification': establishment.identification if establishment.identification else None


            })

            serializer.is_valid(raise_exception=True)
            return Response(serializer.data)
        except Exception as e:
            print("Error: ", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class EstablishmentDetailUserSession(APIView):
    """
    Endpoint para obtener una entidad.

    Args:
       RetrieveAPIView (_type_): The RetrieveAPIView class is a generic view
       that provides a list of objects.

    Returns:
        EstablishmentDetail: An instance of the EstablishmentDetail class.
    """
    serializer_class = EstablishmentCreateResponseSerializer
    permission_classes = [IsAuthenticated]

    def __init__(self):
        """
        The constructor for the EstablishmentDetail class.
        """
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())

    def get(self, request):
        """
        Get a establishment.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """

        try:

            user_id = request.user.pk
            establishment = self.establishment_service.get_establishment_by_user_id(
                user_id)
            info = self.establishment_service.get_first_access_to_information(
                establishment.id)
            law_enforcement = self.law_enforcement.get_law_enforcement_by_establishment(
                establishment.id)
            serializer = self.serializer_class(data={
                'id': establishment.id,
                'name': establishment.name,
                'abbreviation': establishment.abbreviation,
                'logo': establishment.logo.url if establishment.logo else None,
                'highest_authority': establishment.highest_authority,
                'first_name_authority': establishment.first_name_authority,
                'last_name_authority': establishment.last_name_authority,
                'job_authority': establishment.job_authority,
                'email_authority': establishment.email_authority,
                'highest_committe': law_enforcement.highest_committe if law_enforcement is not None else None,
                'first_name_committe': law_enforcement.first_name_committe if law_enforcement is not None else None,
                'last_name_committe': law_enforcement.last_name_committe if law_enforcement is not None else None,
                'job_committe': law_enforcement.job_committe if law_enforcement is not None else None,
                'email_committe': law_enforcement.email_committe if law_enforcement is not None else None,
                'email_accesstoinformation': info.email if info is not None else None,
                'address': establishment.address if establishment.address else '',
                'type_institution': establishment.type_institution.id if establishment.type_institution else None,
                'type_organization': establishment.type_organization.id if establishment.type_organization else None,
                'function_organization': establishment.function_organization.id if establishment.function_organization else None,
                'identification': establishment.identification if establishment.identification else None

            })

            serializer.is_valid(raise_exception=True)
            return Response(serializer.data)
        except Exception as e:
            print("Error: ", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )

            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class EstablismentUpdate(APIView):
    """
    Endpoint para actualizar una entidad.

    Args:
       UpdateAPIView (_type_): The UpdateAPIView class is a generic view
       that provides a list of objects.

    Returns:
        EstablismentUpdate: An instance of the EstablismentUpdate class.
    """
    serializer_class = EstablishmentCreateSerializer
    permission_classes = [IsAuthenticated]
    output_serializer_class = EstablishmentCreateResponseSerializer

    def __init__(self):
        """
        The constructor for the EstablismentUpdate class.
        """
        self.establisment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.access_info = AccessInformationService(AccessInformationImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())

    def put(self, request, pk, *args, **kwargs):
        """
        Update a establishment.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        data = self.serializer_class(data=request.data)
        file = request.FILES['logo'] if 'logo' in request.FILES else None
        data.is_valid(raise_exception=True)
        establishment = None
        law = None
        access = None

        try:
            establishment = self.establisment_service.update_establishment(
                pk, data.data)
            if file is not None:
                self.establisment_service.update_logo(pk, file)
            law = self.law_enforcement.update_law_enforcement_by_establishment_id(
                pk, data.data)
            access = self.access_info.update_access_information_by_establishment_id(
                pk, data.data)

            serializer = self.output_serializer_class(data={
                'id': establishment.id,
                'name': establishment.name,
                'abbreviation': establishment.abbreviation,
                'logo': establishment.logo.url if establishment.logo else None,
                'highest_authority': establishment.highest_authority,
                'first_name_authority': establishment.first_name_authority,
                'last_name_authority': establishment.last_name_authority,
                'job_authority': establishment.job_authority,
                'email_authority': establishment.email_authority,
                'highest_committe': law.highest_committe if law is not None else None,
                'first_name_committe': law.first_name_committe if law is not None else None,
                'last_name_committe': law.last_name_committe if law is not None else None,
                'job_committe': law.job_committe if law is not None else None,
                'email_committe': law.email_committe if law is not None else None,
                'email_accesstoinformation': access.email if access is not None else None,
                'address': establishment.address if establishment.address else '',
                'type_institution': establishment.type_institution.id if establishment.type_institution else None,
                'type_organization': establishment.type_organization.id if establishment.type_organization else None,
                'function_organization': establishment.function_organization.id if establishment.function_organization else None,
                'identification': establishment.identification if establishment.identification else ''


            })
            serializer.is_valid(raise_exception=True)
            res = MessageTransactional(
                data={
                    'message': 'Entidad creada correctamente',
                    'status': 201,
                    'json': serializer.data
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=201)
        except Exception as e:

            print("Error:  ", e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )
            res.is_valid(raise_exception=True)
            return Response(res.data, status=400)


class EstablishmentDeactive(APIView):
    """
    Endpoint para desactivar una entidad.

    Args:
       UpdateAPIView (_type_): The UpdateAPIView class is a generic view
       that provides a list of objects.

    Returns:
        EstablishmentDeactive: An instance of the EstablishmentDeactive class.
    """
    permission_classes = [IsAuthenticated]

    def __init__(self):
        """
        The constructor for the EstablishmentDeactive class.
        """
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())

    def get_queryset(self):
        return self.establishment_service.get_establishments()

    def delete(self, request, pk, *args, **kwargs):
        """
        Deactivate a establishment.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        establishment = self.establishment_service.activa_or_deactivate_establishment(
            pk)
        message = 'Entidad desactivada correctamente' if establishment.deleted else 'Entidad activada correctamente'
        res = MessageTransactional(
            data={
                'message': message,
                'status': 200,
                'json': {}
            }
        )
        res.is_valid(raise_exception=True)
        return Response(res.data, status=200)


class FieldForFormCreate(APIView):

    permission_classes = []

    def get(self, request):
        """
        Get a establishment.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        respository_type = FunctionOrganizationImpl()
        repository_institution = TypeInstitutionImpl()
        repository_organization = TypeOrganizationImpl()

        return Response({
            'functions': [{'id': x.id, 'name': x.name} for x in respository_type.get_all()],
            'institutions': [{'id': x.id, 'name': x.name} for x in repository_institution.get_all()],
            'organizations': [{'id': x.id, 'name': x.name} for x in repository_organization.get_all()]
        })
