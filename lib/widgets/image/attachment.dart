class Attachment {
  const Attachment(this.url, this.type);

  factory Attachment.fromJSON(Map data) {
    return Attachment(data['url'], AttachmentType.values.byName(data['type']));
  }

  bool get isImage => type == AttachmentType.image;
  bool get isVideo => type == AttachmentType.video;

  final AttachmentType type;
  final String url;
}

enum AttachmentType {image, video}