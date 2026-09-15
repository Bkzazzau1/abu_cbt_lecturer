import 'package:flutter/material.dart';

import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import '../../lecturer_workflow/services/lecturer_exam_script_pdf_service.dart';
import 'lecturer_connected_marking_panel.dart';

class LecturerPdfEnabledMarkingPanel extends StatefulWidget {
  const LecturerPdfEnabledMarkingPanel({
    super.key,
    this.section = 'Marking & Grading',
  });

  final String section;

  @override
  State<LecturerPdfEnabledMarkingPanel> createState() =>
      _LecturerPdfEnabledMarkingPanelState();
}

class _LecturerPdfEnabledMarkingPanelState
    extends State<LecturerPdfEnabledMarkingPanel> {
  final LecturerDemoState _state = LecturerDemoState.instance;
  final LecturerExamScriptPdfService _pdfService =
      const LecturerExamScriptPdfService();

  String? _selectedScriptId;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final scripts = _state.scripts;
        final selected = _resolveSelectedScript(scripts);
        final metadata = selected == null ? null : _pdfService.metadataFor(selected);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selected != null && metadata != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(selected.id),
                          initialValue: selected.id,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Exam Script PDF',
                            prefixIcon: Icon(Icons.picture_as_pdf_outlined),
                          ),
                          items: [
                            for (final script in scripts)
                              DropdownMenuItem(
                                value: script.id,
                                child: Text(
                                  '${_pdfService.metadataFor(script).matricNumber} • ${script.courseCode}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: _busy
                              ? null
                              : (value) =>
                                  setState(() => _selectedScriptId = value),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runPdfAction(
                                  () => _pdfService.downloadScript(selected),
                                ),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download PDF'),
                      ),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _runPdfAction(
                                  () => _pdfService.printScript(selected),
                                ),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Print Script'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            LecturerConnectedMarkingPanel(section: widget.section),
          ],
        );
      },
    );
  }

  LecturerDemoExamScript? _resolveSelectedScript(
    List<LecturerDemoExamScript> scripts,
  ) {
    if (scripts.isEmpty) return null;

    if (_selectedScriptId != null) {
      for (final script in scripts) {
        if (script.id == _selectedScriptId) return script;
      }
    }

    _selectedScriptId = scripts.first.id;
    return scripts.first;
  }

  Future<void> _runPdfAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to prepare the exam script PDF.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
