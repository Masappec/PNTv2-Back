
from rest_framework.permissions import BasePermission
from django.contrib.auth.models import User

from entity_app.domain.models.publication import Publication
from entity_app.domain.models.solicity import SolicityResponse
from entity_app.domain.models.establishment import UserEstablishmentExtended
from entity_app.domain.models.transparency_active import EstablishmentNumeral


class HasPermission(BasePermission):

    def has_permission(self, request, view):

        permission_required = getattr(view, 'permission_required', None)

        if request.user.is_superuser:
            return True

        user_id = request.user.id

        is_permited = User.objects.get(id=user_id).groups.filter(
            permissions__codename=permission_required).exists()
        return is_permited


class IsOwnerResponseSolicity(BasePermission):
    def has_object_permission(self, request, view, obj):

        if isinstance(obj, SolicityResponse):
            if obj.user.id == request.user.id:
                return True
        return False


class BelongsToEstablishment(BasePermission):
    def has_permission(self, request, view):

        if request.method == 'POST':
            establishment_id = request.data.get('establishment_id')
        else:
            establishment_id = request.query_params.get('establishtment_id')
        if request.user.is_superuser:
            return True

        valid = UserEstablishmentExtended.objects.filter(
            user_id=request.user, establishment_id=establishment_id).exists()

        return valid


class NumeralIsOwner(BasePermission):

    def has_permission(self, request, view):
        id_numeral = request.query_params.get('numeral_id')

        if request.user.is_superuser:
            return True

        valid = UserEstablishmentExtended.objects.filter(
            user_id=request.user).first()

        valid_numeral = EstablishmentNumeral.objects.filter(
            establishment_id=valid.establishment_id, numeral_id=id_numeral)

        if valid_numeral.count() > 0:
            return True

        return False


class IsPublicPublication(BasePermission):
    def has_object_permission(self, request, view, obj):

        if isinstance(obj, Publication):
            if obj.type_publication.code == 'TA':
                return True
        return False
