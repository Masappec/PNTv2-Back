from django.urls import path,include
from entity_app.application.views.public import PublicationPublicView,PublicationDetail 
from entity_app.application.views.publication import PublicationCreateAPI, PublicationUpdateAPI,\
    PublicationsView, PublicatioDetail,PublicationUpdateState

from entity_app.application.views.file_publication import FilePublicationCreateView, FilePublicationListEstablishemtSession, FilePublicationDelete
from entity_app.application.views.tag import TagView, TagCreateView
from entity_app.application.views.attachment import AttachmentCreateView
from entity_app.application.views.solicity import SolicityView, SolicityCreateView, SolicityResponseView, SolicityCreateResponseView

from entity_app.application.views.numeral import NumeralsByEstablishment, NumeralDetail

from entity_app.application.views.template_file import TemplateFileValidate

urlpatterns = [

    path('public/transparency/active/list', PublicationPublicView.as_view(), name='publication-list'),
    path('public/transparency/active/detail/<slug>', PublicationDetail.as_view(), name='publication-detail'),
 
    
    
    path('publications/file/create', FilePublicationCreateView.as_view(), name='file-publication-create'),
    path('publications/file/list', FilePublicationListEstablishemtSession.as_view(), name='file-publication-list'),
    path('publications/file/delete/<pk>', FilePublicationDelete.as_view(), name='file-publication-delete'),
    
    path('tags/list', TagView.as_view(), name='tag-list'),
    path('tags/create', TagCreateView.as_view(), name='tag-create'),
    
    
    path('publications/list', PublicationsView.as_view(), name='publications-all'),
    path('publications/detail/<pk>', PublicatioDetail.as_view(), name='publications-detail'),
    path('publications/create', PublicationCreateAPI.as_view(), name='publication-create'),
    path('publications/edit/<pk>', PublicationUpdateAPI.as_view(), name='publication-edit'),
    path('publications/state/<pk>', PublicationUpdateState.as_view(), name='publication-inactivate'),
    
    path('attachments/create', AttachmentCreateView.as_view(), name='attachment-create'),

    path('solicity/list', SolicityView.as_view(), name='solicity-all'),
    path('solicity/create', SolicityCreateView.as_view(), name='solicity-create'),
    path('solicity_response/list', SolicityResponseView.as_view(), name='solicity-response-all'),
    path('solicity_response/create', SolicityCreateResponseView.as_view(), name='solicity-response-create'),
    
    
    
    path('numerals/', NumeralsByEstablishment.as_view(), name='numerals-by-establishment'),
    path('numerals/detail/', NumeralDetail.as_view(), name='numeral-detail'),
    
    
    path('template_file/validate', TemplateFileValidate.as_view(), name='template-file-validate'),
]