// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../rendering/mock_canvas.dart';

void main() {
  test('SwitchThemeData copyWith, ==, hashCode basics', () {
    expect(const SwitchThemeData(), const SwitchThemeData().copyWith());
    expect(const SwitchThemeData().hashCode, const SwitchThemeData().copyWith().hashCode);
  });

  test('SwitchThemeData lerp special cases', () {
    const SwitchThemeData data = SwitchThemeData();
    expect(identical(SwitchThemeData.lerp(data, data, 0.5), data), true);
  });

  test('SwitchThemeData defaults', () {
    const SwitchThemeData themeData = SwitchThemeData();
    expect(themeData.thumbColor, null);
    expect(themeData.trackColor, null);
    expect(themeData.trackOutlineColor, null);
    expect(themeData.mouseCursor, null);
    expect(themeData.materialTapTargetSize, null);
    expect(themeData.overlayColor, null);
    expect(themeData.splashRadius, null);
    expect(themeData.thumbIcon, null);

    const SwitchTheme theme = SwitchTheme(data: SwitchThemeData(), child: SizedBox());
    expect(theme.data.thumbColor, null);
    expect(theme.data.trackColor, null);
    expect(theme.data.trackOutlineColor, null);
    expect(theme.data.mouseCursor, null);
    expect(theme.data.materialTapTargetSize, null);
    expect(theme.data.overlayColor, null);
    expect(theme.data.splashRadius, null);
    expect(theme.data.thumbIcon, null);
  });

  testWidgets('Default SwitchThemeData debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const SwitchThemeData().debugFillProperties(builder);

    final List<String> description = builder.properties
      .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
      .map((DiagnosticsNode node) => node.toString())
      .toList();

    expect(description, <String>[]);
  });

  testWidgets('SwitchThemeData implements debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const SwitchThemeData(
      thumbColor: MaterialStatePropertyAll<Color>(Color(0xfffffff0)),
      trackColor: MaterialStatePropertyAll<Color>(Color(0xfffffff1)),
      trackOutlineColor: MaterialStatePropertyAll<Color>(Color(0xfffffff3)),
      mouseCursor: MaterialStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: MaterialStatePropertyAll<Color>(Color(0xfffffff2)),
      splashRadius: 1.0,
      thumbIcon: MaterialStatePropertyAll<Icon>(Icon(IconData(123))),
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
      .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
      .map((DiagnosticsNode node) => node.toString())
      .toList();

    expect(description[0], 'thumbColor: MaterialStatePropertyAll(Color(0xfffffff0))');
    expect(description[1], 'trackColor: MaterialStatePropertyAll(Color(0xfffffff1))');
    expect(description[2], 'trackOutlineColor: MaterialStatePropertyAll(Color(0xfffffff3))');
    expect(description[3], 'materialTapTargetSize: MaterialTapTargetSize.shrinkWrap');
    expect(description[4], 'mouseCursor: MaterialStatePropertyAll(SystemMouseCursor(click))');
    expect(description[5], 'overlayColor: MaterialStatePropertyAll(Color(0xfffffff2))');
    expect(description[6], 'splashRadius: 1.0');
    expect(description[7], 'thumbIcon: MaterialStatePropertyAll(Icon(IconData(U+0007B)))');
  });

  testWidgets('Switch is themeable', (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;

    const Color defaultThumbColor = Color(0xfffffff0);
    const Color selectedThumbColor = Color(0xfffffff1);
    const Color defaultTrackColor = Color(0xfffffff2);
    const Color selectedTrackColor = Color(0xfffffff3);
    const Color defaultTrackOutlineColor = Color(0xfffffff4);
    const Color selectedTrackOutlineColor = Color(0xfffffff5);
    const MouseCursor mouseCursor = SystemMouseCursors.text;
    const MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap;
    const Color focusOverlayColor = Color(0xfffffff4);
    const Color hoverOverlayColor = Color(0xfffffff5);
    const double splashRadius = 1.0;
    const Icon icon1 = Icon(Icons.check);
    const Icon icon2 = Icon(Icons.close);

    final ThemeData themeData = ThemeData(
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return selectedThumbColor;
          }
          return defaultThumbColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return selectedTrackColor;
          }
          return defaultTrackColor;
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return selectedTrackOutlineColor;
          }
          return defaultTrackOutlineColor;
        }),
        mouseCursor: const MaterialStatePropertyAll<MouseCursor>(mouseCursor),
        materialTapTargetSize: materialTapTargetSize,
        overlayColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return focusOverlayColor;
          }
          if (states.contains(MaterialState.hovered)) {
            return hoverOverlayColor;
          }
          return null;
        }),
        splashRadius: splashRadius,
        thumbIcon: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return icon1;
          }
          return icon2;
        }),
      ),
    );
    final bool material3 = themeData.useMaterial3;
    Widget buildSwitch({bool selected = false, bool autofocus = false}) {
      return MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: Switch(
            dragStartBehavior: DragStartBehavior.down,
            value: selected,
            onChanged: (bool value) {},
            autofocus: autofocus,
          ),
        ),
      );
    }

    // Switch.
    await tester.pumpWidget(buildSwitch());
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
      material3
      ? (paints
        ..rrect(color: defaultTrackColor)
        ..rrect(color: defaultTrackOutlineColor)
        ..rrect(color: defaultThumbColor)
        ..paragraph()
      )
      : (paints
        ..rrect(color: defaultTrackColor)
        ..rrect(color: defaultTrackOutlineColor)
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: defaultThumbColor)
      )
    );
    // Size from MaterialTapTargetSize.shrinkWrap.
    expect(tester.getSize(find.byType(Switch)), material3 ? const Size(60.0, 40.0) : const Size(59.0, 40.0));

    // Selected switch.
    await tester.pumpWidget(buildSwitch(selected: true));
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
      material3
      ? (paints
        ..rrect(color: selectedTrackColor)
        ..rrect(color: selectedTrackOutlineColor)
        ..rrect(color: selectedThumbColor)..paragraph())
      : (paints
        ..rrect(color: selectedTrackColor)
        ..rrect(color: selectedTrackOutlineColor)
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: selectedThumbColor))
    );

    // Switch with hover.
    await tester.pumpWidget(buildSwitch());
    await _pointGestureToSwitch(tester);
    await tester.pumpAndSettle();
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1), SystemMouseCursors.text);
    expect(_getSwitchMaterial(tester), paints..circle(color: hoverOverlayColor));

    // Switch with focus.
    await tester.pumpWidget(buildSwitch(autofocus: true));
    await tester.pumpAndSettle();
    expect(_getSwitchMaterial(tester), paints..circle(color: focusOverlayColor, radius: splashRadius));
  });

  testWidgets('Switch properties are taken over the theme values', (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;

    const Color themeDefaultThumbColor = Color(0xfffffff0);
    const Color themeSelectedThumbColor = Color(0xfffffff1);
    const Color themeDefaultTrackColor = Color(0xfffffff2);
    const Color themeSelectedTrackColor = Color(0xfffffff3);
    const Color themeDefaultOutlineColor = Color(0xfffffff6);
    const Color themeSelectedOutlineColor = Color(0xfffffff7);
    const MouseCursor themeMouseCursor = SystemMouseCursors.click;
    const MaterialTapTargetSize themeMaterialTapTargetSize = MaterialTapTargetSize.padded;
    const Color themeFocusOverlayColor = Color(0xfffffff4);
    const Color themeHoverOverlayColor = Color(0xfffffff5);
    const double themeSplashRadius = 1.0;

    const Color defaultThumbColor = Color(0xffffff0f);
    const Color selectedThumbColor = Color(0xffffff1f);
    const Color defaultTrackColor = Color(0xffffff2f);
    const Color selectedTrackColor = Color(0xffffff3f);
    const Color defaultOutlineColor = Color(0xffffff6f);
    const Color selectedOutlineColor = Color(0xffffff7f);
    const MouseCursor mouseCursor = SystemMouseCursors.text;
    const MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap;
    const Color focusColor = Color(0xffffff4f);
    const Color hoverColor = Color(0xffffff5f);
    const double splashRadius = 2.0;

    final ThemeData themeData = ThemeData(
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeSelectedThumbColor;
          }
          return themeDefaultThumbColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeSelectedTrackColor;
          }
          return themeDefaultTrackColor;
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeSelectedOutlineColor;
          }
          return themeDefaultOutlineColor;
        }),
        mouseCursor: const MaterialStatePropertyAll<MouseCursor>(themeMouseCursor),
        materialTapTargetSize: themeMaterialTapTargetSize,
        overlayColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return themeFocusOverlayColor;
          }
          if (states.contains(MaterialState.hovered)) {
            return themeHoverOverlayColor;
          }
          return null;
        }),
        splashRadius: themeSplashRadius,
        thumbIcon: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return null;
          }
          return null;
        }),
      ),
    );
    final bool material3 = themeData.useMaterial3;

    Widget buildSwitch({bool selected = false, bool autofocus = false}) {
      return MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: Switch(
            value: selected,
            onChanged: (bool value) {},
            autofocus: autofocus,
            thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return selectedThumbColor;
              }
              return defaultThumbColor;
            }),
            trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return selectedTrackColor;
              }
              return defaultTrackColor;
            }),
            trackOutlineColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return selectedOutlineColor;
              }
              return defaultOutlineColor;
            }),
            mouseCursor: mouseCursor,
            materialTapTargetSize: materialTapTargetSize,
            focusColor: focusColor,
            hoverColor: hoverColor,
            splashRadius: splashRadius,
            thumbIcon: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Icon(Icons.add);
              }
              return const Icon(Icons.access_alarm);
            }),
          ),
        ),
      );
    }

    // Switch.
    await tester.pumpWidget(buildSwitch());
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
      material3
      ? (paints
        ..rrect(color: defaultTrackColor)
        ..rrect(color: defaultOutlineColor)
        ..rrect(color: defaultThumbColor)..paragraph(offset: const Offset(12, 16)))
      : (paints
        ..rrect(color: defaultTrackColor)
        ..rrect(color: defaultOutlineColor)
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: defaultThumbColor))
    );
    // Size from MaterialTapTargetSize.shrinkWrap.
    expect(tester.getSize(find.byType(Switch)), material3 ? const Size(60.0, 40.0) : const Size(59.0, 40.0));

    // Selected switch.
    await tester.pumpWidget(buildSwitch(selected: true));
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
      material3
      ? (paints
        ..rrect(color: selectedTrackColor)..rrect(color: selectedOutlineColor)
        ..rrect(color: selectedThumbColor))
      : (paints
        ..rrect(color: selectedTrackColor)
        ..rrect(color: selectedOutlineColor)
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: selectedThumbColor))
    );

    // Switch with hover.
    await tester.pumpWidget(buildSwitch());
    await _pointGestureToSwitch(tester);
    await tester.pumpAndSettle();
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1), SystemMouseCursors.text);
    expect(_getSwitchMaterial(tester), paints..circle(color: hoverColor));

    // Switch with focus.
    await tester.pumpWidget(buildSwitch(autofocus: true));
    await tester.pumpAndSettle();
    expect(_getSwitchMaterial(tester), paints..circle(color: focusColor, radius: splashRadius));
  });

  testWidgets('Switch active and inactive properties are taken over the theme values', (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;

    const Color themeDefaultThumbColor = Color(0xfffffff0);
    const Color themeSelectedThumbColor = Color(0xfffffff1);
    const Color themeDefaultTrackColor = Color(0xfffffff2);
    const Color themeSelectedTrackColor = Color(0xfffffff3);

    const Color defaultThumbColor = Color(0xffffff0f);
    const Color selectedThumbColor = Color(0xffffff1f);
    const Color defaultTrackColor = Color(0xffffff2f);
    const Color selectedTrackColor = Color(0xffffff3f);

    final ThemeData themeData = ThemeData(
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeSelectedThumbColor;
          }
          return themeDefaultThumbColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return themeSelectedTrackColor;
          }
          return themeDefaultTrackColor;
        }),
      ),
    );
    final bool material3 = themeData.useMaterial3;

    Widget buildSwitch({bool selected = false, bool autofocus = false}) {
      return MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: Switch(
            value: selected,
            onChanged: (bool value) {},
            autofocus: autofocus,
            activeColor: selectedThumbColor,
            inactiveThumbColor: defaultThumbColor,
            activeTrackColor: selectedTrackColor,
            inactiveTrackColor: defaultTrackColor,
          ),
        ),
      );
    }

    // Unselected switch.
    await tester.pumpWidget(buildSwitch());
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
        material3
        ? (paints
          ..rrect(color: defaultTrackColor)
          ..rrect(color: themeData.colorScheme.outline)
          ..rrect(color: defaultThumbColor))
        : (paints
          ..rrect(color: defaultTrackColor)
          ..rrect()
          ..rrect()
          ..rrect()
          ..rrect(color: defaultThumbColor))
    );

    // Selected switch.
    await tester.pumpWidget(buildSwitch(selected: true));
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
      material3
      ? (paints
        ..rrect(color: selectedTrackColor)
        ..rrect(color: selectedThumbColor))
      : (paints
        ..rrect(color: selectedTrackColor)
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: selectedThumbColor))
    );
  });

  testWidgets('Switch theme overlay color resolves in active/pressed states', (WidgetTester tester) async {
    const Color activePressedOverlayColor = Color(0xFF000001);
    const Color inactivePressedOverlayColor = Color(0xFF000002);

    Color? getOverlayColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        if (states.contains(MaterialState.selected)) {
          return activePressedOverlayColor;
        }
        return inactivePressedOverlayColor;
      }
      return null;
    }
    const double splashRadius = 24.0;
    final ThemeData themeData = ThemeData(
      switchTheme: SwitchThemeData(
        overlayColor: MaterialStateProperty.resolveWith(getOverlayColor),
        splashRadius: splashRadius,
      ),
    );
    final bool material3 = themeData.useMaterial3;

    Widget buildSwitch({required bool active}) {
      return MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: Switch(
            value: active,
            onChanged: (_) { },
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSwitch(active: false));
    await tester.press(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      _getSwitchMaterial(tester),
      material3
      ? ((paints
        ..rrect()
        ..rrect())
        ..circle(
          color: inactivePressedOverlayColor,
          radius: splashRadius,
      ))
      : (paints
        ..rrect()
        ..circle(
          color: inactivePressedOverlayColor,
          radius: splashRadius,
      )),
      reason: 'Inactive pressed Switch should have overlay color: $inactivePressedOverlayColor',
    );

    await tester.pumpWidget(buildSwitch(active: true));
    await tester.press(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      _getSwitchMaterial(tester),
      paints
        ..rrect()
        ..circle(
          color: activePressedOverlayColor,
          radius: splashRadius,
        ),
      reason: 'Active pressed Switch should have overlay color: $activePressedOverlayColor',
    );
  });

  testWidgets('Local SwitchTheme can override global SwitchTheme', (WidgetTester tester) async {
    const Color globalThemeThumbColor = Color(0xfffffff1);
    const Color globalThemeTrackColor = Color(0xfffffff2);
    const Color globalThemeOutlineColor = Color(0xfffffff3);
    const Color localThemeThumbColor = Color(0xffff0000);
    const Color localThemeTrackColor = Color(0xffff0000);
    const Color localThemeOutlineColor = Color(0xffff0000);

    final ThemeData themeData = ThemeData(
      switchTheme: const SwitchThemeData(
        thumbColor: MaterialStatePropertyAll<Color>(globalThemeThumbColor),
        trackColor: MaterialStatePropertyAll<Color>(globalThemeTrackColor),
        trackOutlineColor: MaterialStatePropertyAll<Color>(globalThemeOutlineColor),
      ),
    );
    final bool material3 = themeData.useMaterial3;
    Widget buildSwitch({bool selected = false, bool autofocus = false}) {
      return MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: SwitchTheme(
            data: const SwitchThemeData(
              thumbColor: MaterialStatePropertyAll<Color>(localThemeThumbColor),
              trackColor: MaterialStatePropertyAll<Color>(localThemeTrackColor),
              trackOutlineColor: MaterialStatePropertyAll<Color>(localThemeOutlineColor),
            ),
            child: Switch(
              value: selected,
              onChanged: (bool value) {},
              autofocus: autofocus,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSwitch(selected: true));
    await tester.pumpAndSettle();
    expect(
      _getSwitchMaterial(tester),
      material3
      ? (paints
        ..rrect(color: localThemeTrackColor)
        ..rrect(color: localThemeOutlineColor)
        ..rrect(color: localThemeThumbColor))
      : (paints
        ..rrect(color: localThemeTrackColor)
        ..rrect(color: localThemeOutlineColor)
        ..rrect()
        ..rrect()
        ..rrect()
        ..rrect(color: localThemeThumbColor))
    );
  });
}

Future<void> _pointGestureToSwitch(WidgetTester tester) async {
  final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer();
  addTearDown(gesture.removePointer);
  await gesture.moveTo(tester.getCenter(find.byType(Switch)));
}

MaterialInkController? _getSwitchMaterial(WidgetTester tester) {
  return Material.of(tester.element(find.byType(Switch)));
}
