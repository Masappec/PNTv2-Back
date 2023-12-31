from drf_yasg.utils import swagger_auto_schema
from rest_framework.views import APIView
from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView,DestroyAPIView

from app_admin.adapters.serializer import EstablishmentListSerializer, EstablishmentCreateSerializer, \
    MessageTransactional
from app_admin.utils.pagination import StandardResultsSetPagination
from app_admin.domain.service.establishment_service import EstablishmentService
from app_admin.adapters.impl.establishment_impl import EstablishmentRepositoryImpl
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q

from app_admin.domain.service.access_information_service import AccessInformationService
from app_admin.adapters.impl.access_information_impl import AccessInformationImpl

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
    
    
    #search by username
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
            queryset = queryset.filter(Q(username__icontains=search) | Q(email__icontains=search))
        
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
        self.establishment_service = EstablishmentService(EstablishmentRepositoryImpl())
        self.access_info = AccessInformationService(AccessInformationImpl())

    @swagger_auto_schema(
        operation_description="Create a establishment",
        response={
            201: output_serializer_class,
            400: MessageTransactional
        },
        request_body=serializer_class,
        #form data
        
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
        data=self.serializer_class(data=request.data)
        file = request.FILES['logo']
        data.is_valid(raise_exception=True)
        establishment = None
        try:
            establishment = self.establishment_service.create_establishment(data.data, file)
            access= self.access_info.create_access_information(data.data)
            self.access_info.assign_establishment_to_access_information(access.id, establishment.id)

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
                self.establishment_service.delete_establishment(establishment.id)
            print(e)
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

    def __init__(self):
        """
        The constructor for the EstablismentUpdate class.
        """
        self.establisment_service = EstablishmentService(EstablishmentRepositoryImpl())

    def get_queryset(self):
        return self.establisment_service.get_establishments()

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
        data.is_valid(raise_exception=True)
        establishment = self.establisment_service.update_establishment(pk,data)
        data = MessageTransactional()
        data.message = 'Entidad actualizada correctamente'
        data.data = establishment
        data.status = 200
        data.is_valid(raise_exception=True)
        return Response(data.data)


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
        self.establishment_service = EstablishmentService(EstablishmentRepositoryImpl())

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
        establishment = self.establishment_service.delete_establishment(pk)
        return Response({'message':'Entidad desactivada correctamente'})


