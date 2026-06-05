import 'package:flutter_quill/flutter_quill.dart';

bool isRichToolbarAttributeActive(
  Attribute attribute,
  Map<String, Attribute> attributes,
) {
  if (attribute.key == Attribute.list.key ||
      attribute.key == Attribute.header.key ||
      attribute.key == Attribute.script.key ||
      attribute.key == Attribute.align.key) {
    return attributes[attribute.key]?.value == attribute.value;
  }
  return attributes.containsKey(attribute.key);
}

Attribute richToolbarAttributeForToggle(
  Attribute attribute,
  Map<String, Attribute> attributes,
) {
  return isRichToolbarAttributeActive(attribute, attributes)
      ? Attribute.clone(attribute, null)
      : attribute;
}

void toggleRichToolbarSelection(
  QuillController controller,
  Attribute attribute,
) {
  controller
    ..skipRequestKeyboard = !attribute.isInline
    ..formatSelection(
      richToolbarAttributeForToggle(
        attribute,
        controller.getSelectionStyle().attributes,
      ),
    );
}
