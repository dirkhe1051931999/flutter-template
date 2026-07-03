import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ClientPostMediaGrid extends StatelessWidget {
  const ClientPostMediaGrid({
    super.key,
    required this.imagePaths,
    required this.videoPath,
    required this.onAdd,
    required this.onPreviewImage,
    required this.onPreviewVideo,
    required this.onReorderImage,
    required this.onMoveImage,
    required this.onRemoveImage,
    required this.onRemoveVideo,
  });

  final List<String> imagePaths;
  final String? videoPath;
  final VoidCallback onAdd;
  final ValueChanged<String> onPreviewImage;
  final ValueChanged<String> onPreviewVideo;
  final void Function(int fromIndex, int toIndex) onReorderImage;
  final void Function(int fromIndex, int direction) onMoveImage;
  final ValueChanged<String> onRemoveImage;
  final VoidCallback onRemoveVideo;

  @override
  Widget build(BuildContext context) {
    final hasVideo = videoPath != null;
    final canAdd = !hasVideo && imagePaths.length < 9;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final tileSize = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            if (hasVideo)
              _VideoTile(
                  path: videoPath!,
                  size: tileSize,
                  onPreview: () => onPreviewVideo(videoPath!),
                  onRemove: onRemoveVideo)
            else
              ...imagePaths.asMap().entries.map(
                    (entry) => _ReorderableImageTile(
                      index: entry.key,
                      path: entry.value,
                      size: tileSize,
                      onPreview: () => onPreviewImage(entry.value),
                      onReorder: onReorderImage,
                      onMove: onMoveImage,
                      onRemove: () => onRemoveImage(entry.value),
                    ),
                  ),
            if (canAdd)
              SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: _AddTile(onTap: onAdd)),
          ],
        );
      },
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(4)),
        child: const Center(
            child:
                Icon(CupertinoIcons.add, color: Color(0xFF9B9B9B), size: 34)),
      ),
    );
  }
}

class _ReorderableImageTile extends StatelessWidget {
  const _ReorderableImageTile({
    required this.index,
    required this.path,
    required this.size,
    required this.onPreview,
    required this.onReorder,
    required this.onMove,
    required this.onRemove,
  });

  final int index;
  final String path;
  final double size;
  final VoidCallback onPreview;
  final void Function(int fromIndex, int toIndex) onReorder;
  final void Function(int fromIndex, int direction) onMove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        if (details.data != index) {
          onReorder(details.data, index);
        }
      },
      builder: (context, candidates, rejects) {
        final child = _ImageTile(
            path: path,
            size: size,
            highlighted: candidates.isNotEmpty,
            onPreview: onPreview,
            onRemove: onRemove);
        return Stack(
          children: [
            child,
            Positioned(
              left: 4,
              bottom: 4,
              child: Draggable<int>(
                data: index,
                feedback: Opacity(opacity: 0.88, child: child),
                childWhenDragging: const SizedBox.shrink(),
                child: const _DragHandle(size: 28),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Row(
                children: [
                  _MoveButton(
                      icon: CupertinoIcons.chevron_left,
                      onPressed: () => onMove(index, -1)),
                  const SizedBox(width: 4),
                  _MoveButton(
                      icon: CupertinoIcons.chevron_right,
                      onPressed: () => onMove(index, 1)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile(
      {required this.path,
      required this.size,
      required this.highlighted,
      required this.onPreview,
      required this.onRemove});

  final String path;
  final double size;
  final bool highlighted;
  final VoidCallback onPreview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPreview,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                    color: highlighted
                        ? const Color(0xFF07C160)
                        : const Color(0x00000000),
                    width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: kIsWeb
                      ? _FileFallback(path: path)
                      : Image.file(File(path), fit: BoxFit.cover)),
            ),
          ),
          _RemoveButton(onPressed: onRemove),
        ],
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile(
      {required this.path,
      required this.size,
      required this.onPreview,
      required this.onRemove});

  final String path;
  final double size;
  final VoidCallback onPreview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = path.split(RegExp(r'[\\/]')).last;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPreview,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.play_circle_fill,
                      color: CupertinoColors.white, size: 38),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: CupertinoColors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
          _RemoveButton(onPressed: onRemove),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: const Color(0x99000000),
            borderRadius: BorderRadius.circular(14)),
        child: const Icon(CupertinoIcons.line_horizontal_3,
            color: CupertinoColors.white, size: 16),
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: const Size(28, 28),
      padding: EdgeInsets.zero,
      color: const Color(0x99000000),
      borderRadius: BorderRadius.circular(14),
      onPressed: onPressed,
      child: Icon(icon, color: CupertinoColors.white, size: 16),
    );
  }
}

class _FileFallback extends StatelessWidget {
  const _FileFallback({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final name = path.split(RegExp(r'[\\/]')).last;
    return ColoredBox(
      color: const Color(0xFFF3F3F3),
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis))),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      right: 4,
      child: CupertinoButton(
        minimumSize: const Size(24, 24),
        padding: EdgeInsets.zero,
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(12),
        onPressed: onPressed,
        child: const Icon(CupertinoIcons.xmark,
            size: 13, color: CupertinoColors.white),
      ),
    );
  }
}
