import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006876),
      surfaceTint: Color(0xff006876),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa0efff),
      onPrimaryContainer: Color(0xff004e59),
      secondary: Color(0xff4a6267),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcde7ed),
      onSecondaryContainer: Color(0xff334b4f),
      tertiary: Color(0xff545d7e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffdbe1ff),
      onTertiaryContainer: Color(0xff3c4665),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fafc),
      onSurface: Color(0xff171d1e),
      onSurfaceVariant: Color(0xff3f484a),
      outline: Color(0xff6f797b),
      outlineVariant: Color(0xffbfc8ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff82d3e2),
      primaryFixed: Color(0xffa0efff),
      onPrimaryFixed: Color(0xff001f25),
      primaryFixedDim: Color(0xff82d3e2),
      onPrimaryFixedVariant: Color(0xff004e59),
      secondaryFixed: Color(0xffcde7ed),
      onSecondaryFixed: Color(0xff051f23),
      secondaryFixedDim: Color(0xffb1cbd1),
      onSecondaryFixedVariant: Color(0xff334b4f),
      tertiaryFixed: Color(0xffdbe1ff),
      onTertiaryFixed: Color(0xff101a37),
      tertiaryFixedDim: Color(0xffbcc5eb),
      onTertiaryFixedVariant: Color(0xff3c4665),
      surfaceDim: Color(0xffd5dbdc),
      surfaceBright: Color(0xfff5fafc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe9eff0),
      surfaceContainerHigh: Color(0xffe3e9eb),
      surfaceContainerHighest: Color(0xffdee3e5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003c45),
      surfaceTint: Color(0xff006876),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1a7886),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff223a3f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff597176),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2b3553),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff626c8d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafc),
      onSurface: Color(0xff0c1213),
      onSurfaceVariant: Color(0xff2f383a),
      outline: Color(0xff4b5456),
      outlineVariant: Color(0xff656f71),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff82d3e2),
      primaryFixed: Color(0xff1a7886),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005e6a),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff597176),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff41595e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff626c8d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4a5473),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7c9),
      surfaceBright: Color(0xfff5fafc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe3e9eb),
      surfaceContainerHigh: Color(0xffd8dedf),
      surfaceContainerHighest: Color(0xffcdd3d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003139),
      surfaceTint: Color(0xff006876),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00515c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff183034),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff354d52),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff212b48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3e4867),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafc),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e30),
      outlineVariant: Color(0xff424b4d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff82d3e2),
      primaryFixed: Color(0xff00515c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003941),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff354d52),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff1e363b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3e4867),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff28324f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4babb),
      surfaceBright: Color(0xfff5fafc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f3),
      surfaceContainer: Color(0xffdee3e5),
      surfaceContainerHigh: Color(0xffd0d5d7),
      surfaceContainerHighest: Color(0xffc2c7c9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff82d3e2),
      surfaceTint: Color(0xff82d3e2),
      onPrimary: Color(0xff00363e),
      primaryContainer: Color(0xff004e59),
      onPrimaryContainer: Color(0xffa0efff),
      secondary: Color(0xffb1cbd1),
      onSecondary: Color(0xff1c3439),
      secondaryContainer: Color(0xff334b4f),
      onSecondaryContainer: Color(0xffcde7ed),
      tertiary: Color(0xffbcc5eb),
      onTertiary: Color(0xff252f4d),
      tertiaryContainer: Color(0xff3c4665),
      onTertiaryContainer: Color(0xffdbe1ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e1416),
      onSurface: Color(0xffdee3e5),
      onSurfaceVariant: Color(0xffbfc8ca),
      outline: Color(0xff899295),
      outlineVariant: Color(0xff3f484a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff006876),
      primaryFixed: Color(0xffa0efff),
      onPrimaryFixed: Color(0xff001f25),
      primaryFixedDim: Color(0xff82d3e2),
      onPrimaryFixedVariant: Color(0xff004e59),
      secondaryFixed: Color(0xffcde7ed),
      onSecondaryFixed: Color(0xff051f23),
      secondaryFixedDim: Color(0xffb1cbd1),
      onSecondaryFixedVariant: Color(0xff334b4f),
      tertiaryFixed: Color(0xffdbe1ff),
      onTertiaryFixed: Color(0xff101a37),
      tertiaryFixedDim: Color(0xffbcc5eb),
      onTertiaryFixedVariant: Color(0xff3c4665),
      surfaceDim: Color(0xff0e1416),
      surfaceBright: Color(0xff343a3c),
      surfaceContainerLowest: Color(0xff090f10),
      surfaceContainerLow: Color(0xff171d1e),
      surfaceContainer: Color(0xff1b2122),
      surfaceContainerHigh: Color(0xff252b2c),
      surfaceContainerHighest: Color(0xff303637),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff98e9f9),
      surfaceTint: Color(0xff82d3e2),
      onPrimary: Color(0xff002a31),
      primaryContainer: Color(0xff499cab),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc7e1e7),
      onSecondary: Color(0xff11292e),
      secondaryContainer: Color(0xff7c959a),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd2dbff),
      onTertiary: Color(0xff1a2441),
      tertiaryContainer: Color(0xff8690b2),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1416),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd5dee0),
      outline: Color(0xffaab4b6),
      outlineVariant: Color(0xff899294),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff00505b),
      primaryFixed: Color(0xffa0efff),
      onPrimaryFixed: Color(0xff001418),
      primaryFixedDim: Color(0xff82d3e2),
      onPrimaryFixedVariant: Color(0xff003c45),
      secondaryFixed: Color(0xffcde7ed),
      onSecondaryFixed: Color(0xff001418),
      secondaryFixedDim: Color(0xffb1cbd1),
      onSecondaryFixedVariant: Color(0xff223a3f),
      tertiaryFixed: Color(0xffdbe1ff),
      onTertiaryFixed: Color(0xff050f2c),
      tertiaryFixedDim: Color(0xffbcc5eb),
      onTertiaryFixedVariant: Color(0xff2b3553),
      surfaceDim: Color(0xff0e1416),
      surfaceBright: Color(0xff3f4547),
      surfaceContainerLowest: Color(0xff040809),
      surfaceContainerLow: Color(0xff191f20),
      surfaceContainer: Color(0xff23292a),
      surfaceContainerHigh: Color(0xff2e3435),
      surfaceContainerHighest: Color(0xff393f40),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd1f7ff),
      surfaceTint: Color(0xff82d3e2),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff7ecfde),
      onPrimaryContainer: Color(0xff000d11),
      secondary: Color(0xffdaf5fb),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffaec7cd),
      onSecondaryContainer: Color(0xff000d11),
      tertiary: Color(0xffedefff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffb8c1e6),
      onTertiaryContainer: Color(0xff010926),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1416),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f4),
      outlineVariant: Color(0xffbbc4c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff00505b),
      primaryFixed: Color(0xffa0efff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff82d3e2),
      onPrimaryFixedVariant: Color(0xff001418),
      secondaryFixed: Color(0xffcde7ed),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb1cbd1),
      onSecondaryFixedVariant: Color(0xff001418),
      tertiaryFixed: Color(0xffdbe1ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffbcc5eb),
      onTertiaryFixedVariant: Color(0xff050f2c),
      surfaceDim: Color(0xff0e1416),
      surfaceBright: Color(0xff4b5153),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2122),
      surfaceContainer: Color(0xff2b3133),
      surfaceContainerHigh: Color(0xff363c3e),
      surfaceContainerHighest: Color(0xff424849),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
