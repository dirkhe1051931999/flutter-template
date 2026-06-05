import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:html/parser.dart' as html_parser;
import 'package:oolaf_flutted/components/gallery_preview/index.dart';

class ArticleBodyNode {
  const ArticleBodyNode.text({
    required this.text,
    this.emphasized = false,
  })  : type = ArticleBodyNodeType.text,
        imageUrl = '';

  const ArticleBodyNode.image({
    required this.imageUrl,
  })  : type = ArticleBodyNodeType.image,
        text = '',
        emphasized = false;

  final ArticleBodyNodeType type;
  final String text;
  final String imageUrl;
  final bool emphasized;
}

enum ArticleBodyNodeType {
  text,
  image,
}

class ArticleBodyParseResult {
  const ArticleBodyParseResult({
    required this.imageUrls,
    required this.plainText,
    required this.nodes,
  });

  final List<String> imageUrls;
  final String plainText;
  final List<ArticleBodyNode> nodes;
}

class ArticleBodyHelper {
  const ArticleBodyHelper._();

  static ArticleBodyParseResult parse({
    required String title,
    required String source,
    required String updateTime,
    required String htmlText,
    required String coverUrl,
  }) {
    final document = html_parser.parse(htmlText);
    final body = document.body;

    final imageUrls = <String>[];
    final nodes = <ArticleBodyNode>[];

    void addImageUrl(String url) {
      final trimmedUrl = url.trim();
      if (trimmedUrl.isEmpty || imageUrls.contains(trimmedUrl)) {
        return;
      }
      imageUrls.add(trimmedUrl);
    }

    void addTextNode(String text, {bool emphasized = false}) {
      final normalizedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (normalizedText.isEmpty) {
        return;
      }
      nodes.add(
        ArticleBodyNode.text(
          text: normalizedText,
          emphasized: emphasized,
        ),
      );
    }

    void addImageNode(String imageUrl) {
      final normalizedUrl = imageUrl.trim();
      if (normalizedUrl.isEmpty) {
        return;
      }
      addImageUrl(normalizedUrl);
      nodes.add(ArticleBodyNode.image(imageUrl: normalizedUrl));
    }

    void visitNode(dynamic node, {bool emphasized = false}) {
      final runtimeName = node.runtimeType.toString();
      if (runtimeName == 'Text') {
        final rawText = (node.data ?? '').toString();
        addTextNode(rawText, emphasized: emphasized);
        return;
      }

      if (runtimeName != 'Element') {
        return;
      }

      final localName = (node.localName ?? '').toString().toLowerCase();
      if (localName == 'img') {
        addImageNode((node.attributes['src'] ?? '').toString());
        return;
      }

      if ({'script', 'style'}.contains(localName)) {
        return;
      }

      final childNodes = (node.nodes as List?) ?? const [];
      final childElements = (node.children as List?) ?? const [];
      final blockTags = {
        'p',
        'div',
        'section',
        'article',
        'blockquote',
        'li',
        'figcaption',
      };
      final headingTags = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6'};

      if (headingTags.contains(localName)) {
        addTextNode((node.text ?? '').toString(), emphasized: true);
        for (final child in childElements) {
          final childName = (child.localName ?? '').toString().toLowerCase();
          if (childName == 'img') {
            addImageNode((child.attributes['src'] ?? '').toString());
          }
        }
        return;
      }

      if (blockTags.contains(localName)) {
        var hasImageChild = false;
        for (final child in childElements) {
          final childName = (child.localName ?? '').toString().toLowerCase();
          if (childName == 'img') {
            hasImageChild = true;
            break;
          }
        }
        if (!hasImageChild) {
          addTextNode((node.text ?? '').toString(), emphasized: emphasized);
          return;
        }
      }

      for (final child in childNodes) {
        visitNode(child, emphasized: emphasized);
      }
    }

    addImageUrl(coverUrl);

    if (body != null) {
      for (final node in body.nodes) {
        visitNode(node);
      }
    }

    final bodyText =
        document.body?.text ?? document.documentElement?.text ?? '';
    final plainText =
        '$title\n${'$source  $updateTime'.trim()}\n\n$bodyText'.trim();

    return ArticleBodyParseResult(
      imageUrls: List<String>.unmodifiable(imageUrls),
      plainText: plainText,
      nodes: List<ArticleBodyNode>.unmodifiable(nodes),
    );
  }

  static List<Widget> buildWidgets({
    required BuildContext context,
    required List<ArticleBodyNode> nodes,
    required List<String> galleryImageUrls,
  }) {
    final widgets = <Widget>[];

    for (final node in nodes) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 14));
      }

      if (node.type == ArticleBodyNodeType.image) {
        widgets.add(
          GalleryPreviewImage(
            imageUrl: node.imageUrl,
            galleryImageUrls: galleryImageUrls,
          ),
        );
        continue;
      }

      widgets.add(
        SelectableText(
          node.text,
          style: TextStyle(
            color: const Color(0xFF1C1C1E),
            fontSize: node.emphasized ? 18 : 16,
            height: node.emphasized ? 1.6 : 1.75,
            fontWeight: node.emphasized ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      );
    }

    return widgets;
  }
}
