from rest_framework.views import APIView
from entity_app.domain.services.tag_service import TagService
from entity_app.adapters.impl.tag_impl import TagImpl
from rest_framework.response import Response
from rest_framework import status
from entity_app.adapters.serializers import TagSerializer


class TagView(APIView):

    def __init__(self, **kwargs):

        self.sevice = TagService(TagImpl())

    def get(self, request, *args, **kwargs):
        """
        Get all tags.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:
            search = request.GET.get('search', None)
            if search is not None:
                tags = self.sevice.find_by_name(name=search)
            else:
                tags = self.sevice.find_all()

            return Response(TagSerializer(tags, many=True).data, status=status.HTTP_200_OK)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)


class TagCreateView(APIView):

    serializer_class = TagSerializer

    def __init__(self, **kwargs):

        self.sevice = TagService(TagImpl())

    def post(self, request, *args, **kwargs):
        """
        Post tag.

        Args:
            request (object): The request object.
            *args: Variable length argument list.
            **kwargs: Arbitrary keyword arguments.

        Returns:
            object: The response object.
        """
        try:

            serializer = TagSerializer(data=request.data)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

            tag = self.sevice.save(name=serializer.validated_data['name'])
            return Response(TagSerializer(tag).data, status=status.HTTP_200_OK)

        except Exception as e:

            res = {
                'message': str(e),
                'status': status.HTTP_400_BAD_REQUEST,
                'json': {}
            }

            return Response(res, status=status.HTTP_400_BAD_REQUEST)
