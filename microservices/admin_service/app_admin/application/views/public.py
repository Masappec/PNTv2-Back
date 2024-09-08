from rest_framework.generics import ListAPIView
from rest_framework.response import Response
from django.db.models import Q
from app_admin.domain.service.establishment_service import EstablishmentService
from app_admin.adapters.impl.establishment_impl import EstablishmentRepositoryImpl
from app_admin.adapters.serializer import EstablishmentCreateResponseSerializer, EstablishmentListSerializer, MessageTransactional, \
    PedagogyAreaSerializerResponse
from app_admin.utils.pagination import LetterPagination
from rest_framework.views import APIView
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema
from rest_framework.permissions import IsAuthenticated
from app_admin.utils.permission import HasPermission
from app_admin.domain.service.pedagogy_area_service import PedagogyAreaService
from app_admin.adapters.impl.pedagogy_area_impl import PedagogyAreaImpl
from app_admin.adapters.impl.law_enforcement_impl import LawEnforcementImpl
from app_admin.domain.service.law_enforcement_service import LawEnforcementService


class EstablishmentPublicList(ListAPIView):

    pagination_class = LetterPagination
    serializer_class = EstablishmentListSerializer
    permission_classes = []

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
        return self.user_service.get_public_establishment()

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
        # quiero que en el campo logo me devuelva la url relativa

        search = request.query_params.get('search', None)
        if search is not None:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(abbreviation__icontains=search))
        function = request.query_params.get('funcion', None)
        if function is not None:
            queryset = queryset.filter(function_organization__name=function)
        establishments_by_letter = {}
        for establishment in queryset:
            first_letter = establishment.name[0].upper()
            if first_letter not in establishments_by_letter:
                establishments_by_letter[first_letter] = []
            establishments_by_letter[first_letter].append(
                self.get_serializer(establishment).data)

        result_data = [{'letter': letter, 'data': data}
                       for letter, data in establishments_by_letter.items()]

        result = self.get_paginated_response(result_data)
        return result


class EstablishmentPublicDetail(APIView):
    """
    Endpoint para obtener una entidad.

    Args:
       RetrieveAPIView (_type_): The RetrieveAPIView class is a generic view
       that provides a list of objects.

    Returns:
        EstablishmentDetail: An instance of the EstablishmentDetail class.
    """
    serializer_class = EstablishmentCreateResponseSerializer
    permission_classes = []

    def __init__(self):
        """
        The constructor for the EstablishmentDetail class.
        """
        self.establishment_service = EstablishmentService(
            EstablishmentRepositoryImpl())
        self.law_enforcement = LawEnforcementService(LawEnforcementImpl())

    def get(self, request, slug, *args, **kwargs):
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

            establishment = self.establishment_service.get_establishment_by_slug(
                slug)
            
            info = self.establishment_service.get_first_access_to_information(
                establishment.id)
            law_enforcement = self.law_enforcement.get_law_enforcement_by_establishment(
                establishment.id)
            print("law_enforcemen t", law_enforcement)
            serializer = self.serializer_class(data={
                'id': establishment.id,
                'name': establishment.name,
                'alias':establishment.alias,
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
                'identification': establishment.identification if establishment.identification else '',
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


class PedagogyAreaPublicView(APIView):

    permission_classes = []

    serializer_class = PedagogyAreaSerializerResponse

    def __init__(self):
        self.service = PedagogyAreaService(
            respository=PedagogyAreaImpl()
        )

    def get(self, request, format=None):
        try:
            pedagogy_area = self.service.select_area()

            serializer = self.serializer_class(pedagogy_area)

            res = MessageTransactional(
                data={
                    'message': 'Pedagogy area selected successfully',
                    'status': 200,
                    'json': serializer.data
                }
            )

            res.is_valid(raise_exception=True)

            return Response(res.data, status=status.HTTP_200_OK)

        except Exception as e:
            print(e)
            res = MessageTransactional(
                data={
                    'message': str(e),
                    'status': 400,
                    'json': {}
                }
            )

            res.is_valid(raise_exception=True)

            return Response(res.validated_data, status=status.HTTP_400_BAD_REQUEST)
