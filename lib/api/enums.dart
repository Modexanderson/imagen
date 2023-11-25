enum AIStyle {
  /// Default value when no style is selected
  noStyle, // Default value when no style is selected
  /// Anime style
  anime, // Anime style
  /// Detailed style
  moreDetails, // Detailed style
  /// Cyberpunk style
  cyberPunk, // Cyberpunk style
  /// Kandinsky style
  kandinskyPainter, // Kandinsky style
  /// Aivazovsky style
  aivazovskyPainter, // Aivazovsky style
  /// Malevich style
  malevichPainter, // Malevich style
  /// Picasso style
  picassoPainter, // Picasso style
  /// Goncharova style
  goncharovaPainter, // Goncharova style
  /// Classicism style
  classicism, // Classicism style
  /// Renaissance style
  renaissance, // Renaissance style
  /// Oil painting style
  oilPainting, // Oil painting style
  /// Pencil drawing style
  pencilDrawing, // Pencil drawing style
  /// Digital painting style
  digitalPainting, // Digital painting style
  /// Medieval style
  medievalStyle, // Medieval style
  /// 3D rendering style
  render3D, // 3D rendering style
  /// Cartoon style
  cartoon, // Cartoon
  /// Studio photo style
  studioPhoto, // Studio photo style
  /// Portrait photo style
  portraitPhoto, // Portrait photo style
  /// Khokhloma style
  khokhlomaPainter, // Khokhloma style
  /// Christmas style
  christmas, // Christmas style
}

/// The [Resolution] enum is used to specify the different resolutions that can be used
/// by the AI to generate the image. Each enum value corresponds to a specific
/// width and height.
/// The available resolutions are (width and height):
/// - 1024 x 1024.
/// - 1024 x 576.
/// - 576 x 1024.
/// - 1024 x 680.
/// - 680 x 1024.
enum Resolution {
  ///1024 x 1024
  r1x1,

  ///1024 x 576.
  r16x9,

  ///576 x 1024.
  r9x16,

  ///1024 x 680.
  r3x2,

  ///680 x 1024.
  r2x3
}
