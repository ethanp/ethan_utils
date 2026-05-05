class ImageBytes {
  const ImageBytes._();

  static bool hasSupportedImageHeader(List<int> imageBytes) {
    if (imageBytes.length < 4) return false;
    if (_hasPngHeader(imageBytes)) return true;
    if (_hasJpegHeader(imageBytes)) return true;
    if (_hasGifHeader(imageBytes)) return true;
    return _hasWebpHeader(imageBytes);
  }

  static String headerPreview(List<int> imageBytes, {int byteCount = 16}) {
    if (imageBytes.isEmpty) return '<empty>';

    final headerBytes = imageBytes.take(byteCount).map(_hexByte).join(' ');
    if (imageBytes.length <= byteCount) return headerBytes;
    return '$headerBytes ...';
  }

  static bool _hasPngHeader(List<int> imageBytes) {
    if (imageBytes.length < 8) return false;
    return imageBytes[0] == 0x89 &&
        imageBytes[1] == 0x50 &&
        imageBytes[2] == 0x4E &&
        imageBytes[3] == 0x47 &&
        imageBytes[4] == 0x0D &&
        imageBytes[5] == 0x0A &&
        imageBytes[6] == 0x1A &&
        imageBytes[7] == 0x0A;
  }

  static bool _hasJpegHeader(List<int> imageBytes) {
    return imageBytes[0] == 0xFF &&
        imageBytes[1] == 0xD8 &&
        imageBytes[2] == 0xFF;
  }

  static bool _hasGifHeader(List<int> imageBytes) {
    return imageBytes[0] == 0x47 &&
        imageBytes[1] == 0x49 &&
        imageBytes[2] == 0x46 &&
        imageBytes[3] == 0x38;
  }

  static bool _hasWebpHeader(List<int> imageBytes) {
    if (imageBytes.length < 12) return false;
    return imageBytes[0] == 0x52 &&
        imageBytes[1] == 0x49 &&
        imageBytes[2] == 0x46 &&
        imageBytes[3] == 0x46 &&
        imageBytes[8] == 0x57 &&
        imageBytes[9] == 0x45 &&
        imageBytes[10] == 0x42 &&
        imageBytes[11] == 0x50;
  }

  static String _hexByte(int imageByte) =>
      imageByte.toRadixString(16).padLeft(2, '0');
}
