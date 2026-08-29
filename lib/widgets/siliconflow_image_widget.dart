import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_generation_provider.dart';

/// Widget to display generated images from SiliconFlow
class SiliconFlowImageWidget extends ConsumerWidget {
  final String prompt;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SiliconFlowImageWidget({
    Key? key,
    required this.prompt,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(generateImageProvider(prompt));

    return imageAsync.when(
      data: (imageUrl) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(context, error.toString());
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
      },
      loading: () {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (err, stack) {
        return _buildErrorWidget(context, err.toString());
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 32),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for case header image with title overlay
class CaseHeaderImageWidget extends ConsumerWidget {
  final String caseTitle;
  final String category;
  final VoidCallback? onRetry;

  const CaseHeaderImageWidget({
    Key? key,
    required this.caseTitle,
    required this.category,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(
      generateCaseHeaderImageProvider(
        (caseTitle: caseTitle, category: category),
      ),
    );

    return imageAsync.when(
      data: (imageUrl) {
        return Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      caseTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (err, stack) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.red[50],
            border: Border.all(color: Colors.red[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 48),
              const SizedBox(height: 8),
              Text(
                'Failed to load header image',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[600],
                    ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Widget for case timeline visualization
class CaseTimelineVisualizationWidget extends ConsumerWidget {
  final String caseType;
  final List<String> stages;
  final double? imageHeight;

  const CaseTimelineVisualizationWidget({
    Key? key,
    required this.caseType,
    required this.stages,
    this.imageHeight = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineImagesAsync = ref.watch(
      generateTimelineImagesProvider(
        (caseType: caseType, stages: stages),
      ),
    );

    return timelineImagesAsync.when(
      data: (images) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              images.length,
              (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == images.length - 1 ? 16 : 8,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          images[index],
                          width: 200,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: imageHeight,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stage ${index + 1}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (index < stages.length)
                        Text(
                          stages[index],
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () {
        return Container(
          height: (imageHeight ?? 180) + 50,
          color: Colors.grey[100],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (err, stack) {
        return Container(
          height: (imageHeight ?? 180) + 50,
          color: Colors.red[50],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[300], size: 32),
                const SizedBox(height: 8),
                Text(
                  'Failed to generate timeline images',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red[600],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}