from django.urls import path
from app.domain.views.user import UserListAPI, UserCreateAPI, UserUpdate,UserDeactivate
from app.domain.views.auth import LoginApiView, RegisterApiView
from app.domain.views.permission import PermissionListAPI
from app.domain.views.role import RoleListAPI, RoleCreateAPI, RoleUpdateAPI, RoleDetailAPI,RoleDeleteAPI
from rest_framework_simplejwt.views import  TokenRefreshView,TokenVerifyView

urlpatterns = [
    path('user/list', UserListAPI.as_view(), name='user-list'),
    path('user/create', UserCreateAPI.as_view(), name='user-create'),
    path('user/update/<pk>', UserUpdate.as_view(), name=""),
    path("user/delete/<pk>", UserDeactivate.as_view(), name=""),
    
    path('permission/list', PermissionListAPI.as_view(), name='permission-list'),
    
    path("role/list", RoleListAPI.as_view(), name="role-list"),
    path("role/create", RoleCreateAPI.as_view(), name="role-create"),
    path("role/update/<pk>", RoleUpdateAPI.as_view(), name="role-update"),
    path("role/detail/<pk>", RoleDetailAPI.as_view(), name="role-detail"),
    path("role/delete/<pk>", RoleDeleteAPI.as_view(), name="role-delete"),
    
    
    path('login/', LoginApiView.as_view(), name='token_obtain_pair'),
    path('register/',RegisterApiView.as_view(), name='register'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),

]