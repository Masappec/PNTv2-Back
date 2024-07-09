from django.urls import path, include
from entity_app.application.views.public import PublicationPublicView, PublicationDetail
from entity_app.application.views.publication import PublicationCreateAPI, PublicationUpdateAPI, \
    PublicationsView, PublicatioDetail, PublicationUpdateState
from entity_app.application.views.stats import StatsCitizen, IndicatorsEstablishmentView
from entity_app.application.views.file_publication import FilePublicationCreateView, GetFileFromUri, FilePublicationListEstablishemtSession, FilePublicationDelete
from entity_app.application.views.tag import TagView, TagCreateView
from entity_app.application.views.attachment import AttachmentCreateView
from entity_app.application.views.solicity import SolicityView, SolicityCreateDraftView, \
    SolicityResponseView, SolicityCreateResponseView, SolicityWithoutDraftView, CreateExtensionSolicityView,SolicityGetLastDraftView, \
    SolicitySendView, SolicityDetailView, UpdateSolicityView, SolicityChangeStatus, SolicityDetailEstablishmentView, CreateManualSolicity

from entity_app.application.views.numeral import NumeralsByEstablishment, NumeralDetail, ListNumeral, ListNumeralAllow, PublishNumeral, NumeralEditPublish

from entity_app.application.views.colab_transparency import CreateTransparencyColaboraty, TransparencyColaborativeView, \
    TransparencyColaborativeDelete, TransparencyCollabUpdate, TransparecyCollabPublicView
from entity_app.application.views.focus_transparency import CreateTransparencyFocalizada, TransparencyFocusView, \
    TransparencyFocusDelete, TransparencyFocusUpdate, TransparecyFocusPublicView

from entity_app.application.views.template_file import TemplateFileValidate
from entity_app.application.views.transparency_active import TransparencyActivePublicListView

from entity_app.application.views.reports import ArchivosSubidos,ReporteArchivos,ReporteRespuestas,ReporteNoRespuestas,ReporteSolicitudes
from entity_app.application.views.public import MonthForTransparency

urlpatterns = [     
               
     path('stats/citizen', StatsCitizen.as_view(), name='stats-citizen'),
    path("stats/establishment", IndicatorsEstablishmentView.as_view(), name="stats-establishment"),
    path('public/transparency/active/list',
         PublicationPublicView.as_view(), name='publication-list'),
    path('public/transparency/active/detail/<slug>',
         PublicationDetail.as_view(), name='publication-detail'),

    path('publications/file/create', FilePublicationCreateView.as_view(),
         name='file-publication-create'),
    path('publications/file/list', FilePublicationListEstablishemtSession.as_view(),
         name='file-publication-list'),
    path('publications/file/delete/<pk>',
         FilePublicationDelete.as_view(), name='file-publication-delete'),

    path('publications/file/from-uri/', GetFileFromUri.as_view(),
         name='file-publication-get'),

    path('tags/list', TagView.as_view(), name='tag-list'),
    path('tags/create', TagCreateView.as_view(), name='tag-create'),

    path('publications/list', PublicationsView.as_view(), name='publications-all'),
    path('publications/detail/<pk>', PublicatioDetail.as_view(),
         name='publications-detail'),
    path('publications/create', PublicationCreateAPI.as_view(),
         name='publication-create'),
    path('publications/edit/<pk>',
         PublicationUpdateAPI.as_view(), name='publication-edit'),
    path('publications/state/<pk>', PublicationUpdateState.as_view(),
         name='publication-inactivate'),

    path('attachments/create', AttachmentCreateView.as_view(),
         name='attachment-create'),

    path('solicity/list', SolicityView.as_view(), name='solicity-all'),

    path('solicity/detail/<solicity_id>', SolicityDetailView.as_view(),
         name='solicity-detail'),
    path("solicity/update", UpdateSolicityView.as_view(), name="solicity-update"),

    path('solicity/create/draft', SolicityCreateDraftView.as_view(),
         name='solicity-create'),
    path('solicity/comment', CreateExtensionSolicityView.as_view(),name='solicity-comment'),
    path('solicity/change-status', SolicityChangeStatus.as_view(),name='change-status'),
    path('solicity/get_last_draft', SolicityGetLastDraftView.as_view(),
         name='solicity-get-last-draft'),

    path('solicity/send', SolicityWithoutDraftView.as_view(),
         name='solicity-create-without-draft'),
    path('solicity/create_manual', CreateManualSolicity.as_view(),
         name='solicity-create-manual'),

    path('solicity/draft/send', SolicitySendView.as_view(),
         name='solicity-send'),

    path('solicity_response/list', SolicityResponseView.as_view(),
         name='solicity-response-all'),
    path('solicity_response/detail/<solicity_id>', SolicityDetailEstablishmentView.as_view(),
         name='solicity-response-detail'),
    path('solicity_response/create', SolicityCreateResponseView.as_view(),
         name='solicity-response-create'),

    path('numerals/', NumeralsByEstablishment.as_view(),
         name='numerals-by-establishment'),
    path("numerals/allow/", ListNumeralAllow.as_view(), name="numerals-allow"),
    path('numerals/detail/', NumeralDetail.as_view(), name='numeral-detail'),
    path('numerals/transparency', ListNumeral.as_view(),
         name='numero-transparency'),

    path('template_file/validate', TemplateFileValidate.as_view(),
         name='template-file-validate'),

    path('transparency/active/publish',
         PublishNumeral.as_view(), name='numeral-publish'),
    path("transparency/active/update",
         NumeralEditPublish.as_view(), name="numeral-edit-publish"),
    path("transparency/active/public",
         TransparencyActivePublicListView.as_view(), name="transparency-active-public"),

    path('transparency/colaborative/create', CreateTransparencyColaboraty.as_view(),
         name='create-transparency-colaborative'),
    path('transparency/colaborative/list', TransparencyColaborativeView.as_view(),
         name='list-transparency-colaborative'),

    path('transparency/colaborative/delete/<pk>',
         TransparencyColaborativeDelete.as_view(), name='delete-transparency-colaborative'),
    path('transparency/colaborative/update/<pk>',
         TransparencyCollabUpdate.as_view(), name='update-transparency-colaborative'),
    path("transparency/colaborative/public",
         TransparecyCollabPublicView.as_view(), name="transparency-colaborative-public"),
    path("transparency/focus/public",
         TransparecyFocusPublicView.as_view(), name="transparency-focus-public"),

    path('transparency/focus/create', CreateTransparencyFocalizada.as_view(),
         name='create-transparency-focus'),
    path('transparency/focus/update/<pk>',
         TransparencyFocusUpdate.as_view(), name='update-transparency-focus'),
    path('transparency/focus/list', TransparencyFocusView.as_view(),
         name='list-transparency-focus'),
    path('transparency/focus/delete/<pk>',
         TransparencyFocusDelete.as_view(), name='delete-transparency-focus'),
    
     
     
    path('transparency/months', MonthForTransparency.as_view(), name='transparency-months'),
     
    path('reports/view/archivos-subidos', ArchivosSubidos.as_view(), name='reports-view-archivos-subidos'),
    
    
    path('reports/download/archivos-subidos', ReporteArchivos.as_view(),
         name='reports-view-archivos-subidos'),
    # ReporteRespuestas
    path ('reports/download/reporte-respuestas', ReporteRespuestas.as_view(), name='reports-view-reporte-respuestas'),
    
    # ReporteNoRespuestas
     path ('reports/download/reporte-no-respuestas', ReporteNoRespuestas.as_view(), name='reports-view-reporte-no-respuestas'),
     #ReporteSolicitudes
     path ('reports/download/reporte-solicitudes', ReporteSolicitudes.as_view(), name='reports-view-reporte-solicitudes'),
]
