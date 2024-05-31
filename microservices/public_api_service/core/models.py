from mongoengine import Document, StringField, BooleanField, ListField, EmbeddedDocument, EmbeddedDocumentField


class Metadata(EmbeddedDocument):
    filename = StringField(required=True)
    delimiter = StringField(default=",")
    quotechar = StringField(default="\"")
    escapechar = StringField(default="\\")
    has_header = BooleanField(default=True)
    columns = ListField(StringField())
    numeral = StringField(default="decimal")
    article = StringField(default="19")
    month = StringField(default="12")
    year = StringField(default="2019")
    establishment_identification = StringField(default="CNPJ")
    user_upload = StringField(default="user")
    date_upload = StringField(default="date")
    path = StringField(default="path")
    numeral_description = StringField(default="numeral")
    establishment_name = StringField(default="establishment")


class CSVData(Document):
    metadata = EmbeddedDocumentField(Metadata)
    data = ListField(ListField(StringField()))


