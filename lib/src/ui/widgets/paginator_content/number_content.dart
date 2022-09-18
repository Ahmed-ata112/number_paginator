import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:number_paginator/src/ui/widgets/inherited_number_paginator.dart';
import 'package:number_paginator/src/ui/widgets/paginator_button.dart';

class NumberContent extends StatelessWidget {
  final int currentPage;

  const NumberContent({
    Key? key,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /// Buttons have an aspect ratio of 1:1. Therefore use paginator height as
        /// button width.
        var buttonWidth = constraints.maxHeight;
        var availableSpots = (constraints.maxWidth / buttonWidth).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_firstPageShouldStick(context)) _buildPageButton(context, 0),
            if (_frontDotsShouldShow(context, availableSpots))
              _buildDots(context),
            ..._generateCenterButtonList(context, availableSpots),
            if (_backDotsShouldShow(context, availableSpots))
              _buildDots(context),
            if (_lastPageShouldStick(context))
              _buildPageButton(context,
                  InheritedNumberPaginator.of(context).numberPages - 1),
          ],
        );
      },
    );
  }

  /// Generates the variable button list which is at the center of the (optional)
  /// dots. The very last and first pages are shown independently of this list.
  List<Widget> _generateCenterButtonList(
      BuildContext context, int availableSpots) {
    // if dots shown: available minus (2 for first and last pages + 2 for dots)
    var shownPages = availableSpots -
        (_firstPageShouldStick(context) ? 1 : 0) -
        (_lastPageShouldStick(context) ? 1 : 0) -
        (_backDotsShouldShow(context, availableSpots) ? 1 : 0) -
        (_frontDotsShouldShow(context, availableSpots) ? 1 : 0);

    var numberPages = InheritedNumberPaginator.of(context).numberPages;
    int firstPage = (_firstPageShouldStick(context) ? 1 : 0);
    int lastPage = numberPages - (_lastPageShouldStick(context) ? 1 : 0);

    int minValue, maxValue;
    minValue = max(firstPage, currentPage - shownPages ~/ 2);
    maxValue = min(minValue + shownPages, lastPage);

    if (maxValue - minValue < shownPages) {
      minValue = (maxValue - shownPages).clamp(firstPage, lastPage);
    }

    return List.generate(maxValue - minValue,
        (index) => _buildPageButton(context, minValue + index));
  }

  /// Builds a button for the given index.
  Widget _buildPageButton(BuildContext context, int index) => PaginatorButton(
        onPressed: () =>
            InheritedNumberPaginator.of(context).onPageChange?.call(index),
        selected: _selected(index),
        child:
            AutoSizeText((index + 1).toString(), maxLines: 1, minFontSize: 5),
      );

  Widget _buildDots(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: Container(
          // padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.all(4.0),
          alignment: Alignment.bottomCenter,
          decoration: ShapeDecoration(
            shape: InheritedNumberPaginator.of(context).config.buttonShape ??
                const CircleBorder(),
            color: InheritedNumberPaginator.of(context)
                .config
                .buttonUnselectedBackgroundColor,
          ),
          child: Icon(
            Icons.more_horiz,
            color: InheritedNumberPaginator.of(context)
                    .config
                    .buttonUnselectedForegroundColor ??
                Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
        ),
      );

  bool _lastPageShouldStick(BuildContext context) =>
      InheritedNumberPaginator.of(context).config.dotsVisibility ==
          DotsVisibility.bothDots ||
      InheritedNumberPaginator.of(context).config.dotsVisibility ==
          DotsVisibility.backOnly;

  bool _firstPageShouldStick(BuildContext context) =>
      InheritedNumberPaginator.of(context).config.dotsVisibility ==
          DotsVisibility.bothDots ||
      InheritedNumberPaginator.of(context).config.dotsVisibility ==
          DotsVisibility.frontOnly;

  /// Checks if pages don't fit in available spots and dots have to be shown.
  bool _backDotsShouldShow(BuildContext context, int availableSpots) =>
      _lastPageShouldStick(context) &&
      availableSpots < InheritedNumberPaginator.of(context).numberPages &&
      currentPage <
          InheritedNumberPaginator.of(context).numberPages -
              availableSpots ~/ 2;

  bool _frontDotsShouldShow(BuildContext context, int availableSpots) =>
      _firstPageShouldStick(context) &&
      availableSpots < InheritedNumberPaginator.of(context).numberPages &&
      currentPage > availableSpots ~/ 2 - 1;

  /// Checks if the given index is currently selected.
  bool _selected(index) => index == currentPage;
}
