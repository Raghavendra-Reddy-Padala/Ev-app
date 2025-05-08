import 'package:flutter/material.dart';

class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? trailing;
  final bool isUser;
  final dynamic data;

  SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isUser = false,
    this.data,
  });
}
