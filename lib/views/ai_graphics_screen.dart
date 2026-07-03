import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:the_digital_registration/config/ai_graphics_config.dart';
import 'package:the_digital_registration/services/ai_graphics_service.dart';
import 'package:the_digital_registration/theme/app_theme.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

/// AI text-to-image studio for banners, job posts, and marketing graphics.
class AiGraphicsScreen extends StatefulWidget {
  const AiGraphicsScreen({
    super.key,
    this.userData,
    this.initialPrompt,
    this.initialSizeKey = 'banner',
  });

  final Map<String, dynamic>? userData;
  final String? initialPrompt;
  final String initialSizeKey;

  @override
  State<AiGraphicsScreen> createState() => _AiGraphicsScreenState();
}

class _AiGraphicsScreenState extends State<AiGraphicsScreen> {
  final _promptController = TextEditingController();
  final _service = AiGraphicsService();
  String _sizeKey = 'banner';
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sizeKey = AiGraphicsConfig.sizes.containsKey(widget.initialSizeKey)
        ? widget.initialSizeKey
        : 'banner';
    if (widget.initialPrompt != null && widget.initialPrompt!.trim().isNotEmpty) {
      _promptController.text = widget.initialPrompt!.trim();
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      setState(() => _error = 'Describe the graphic you want to create.');
      return;
    }

    final size = AiGraphicsConfig.sizes[_sizeKey]!;
    setState(() {
      _loading = true;
      _error = null;
      _imageUrl = null;
      _imageBytes = null;
    });

    try {
      final result = await _service.generate(
        prompt: prompt,
        width: size.width,
        height: size.height,
      );
      if (!mounted) return;
      setState(() {
        _imageUrl = result.imageUrl;
        _imageBytes = result.bytes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _applyTemplate(String prompt) {
    _promptController.text = prompt;
    setState(() => _error = null);
  }

  void _copyUrl() {
    if (_imageUrl == null) return;
    Clipboard.setData(ClipboardData(text: _imageUrl!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image URL copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = AiGraphicsConfig.sizes[_sizeKey]!;
    final aspect = size.width / size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Graphics Studio'),
        actions: [
          if (_imageUrl != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy image URL',
              onPressed: _copyUrl,
            ),
        ],
      ),
      body: ResponsiveScrollBody(
        children: [
          Card(
            
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.primary, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Describe your banner or poster in English. AI generates a '
                      'unique graphic you can use for job posts, ads, or social media.',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Quick templates', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AiGraphicsConfig.templates.map((t) {
              return ActionChip(
                label: Text(t.title),
                onPressed: () => _applyTemplate(t.prompt),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Your prompt',
              hintText: 'e.g. Modern hiring banner for software internship...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _sizeKey,
            decoration: InputDecoration(
              labelText: 'Image size',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            items: AiGraphicsConfig.sizes.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value.label),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _sizeKey = v);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Generating…' : 'Generate graphic'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 12),
                    Text('Creating your graphic — this may take 15–30 seconds'),
                  ],
                ),
              ),
            ),
          if (_imageUrl != null && !_loading) ...[
            Text('Preview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: aspect,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text('Preview blocked — use Copy URL'),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyUrl,
                    icon: const Icon(Icons.link),
                    label: const Text('Copy URL'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
