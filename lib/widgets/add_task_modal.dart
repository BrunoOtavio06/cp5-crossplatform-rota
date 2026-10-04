import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/app_colors.dart';
import '../core/date_formatters.dart';
import '../data/models/enums.dart';
import '../data/models/models.dart';
import '../data/rota_store.dart';
import 'custom_button.dart';
import 'custom_input.dart';

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key, required this.store, this.existing});

  final RotaStore store;
  final Delivery? existing;

  static Future<void> show(BuildContext context, RotaStore store, {Delivery? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskModal(store: store, existing: existing),
    );
  }

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

/// Disciplinas padrão do semestre, sugeridas no seletor além das que já
/// aparecem nas entregas cadastradas.
const _defaultDisciplines = [
  'Cross-Platform',
  'Redes Neurais',
  'Data-Science',
];

class _AddTaskModalState extends State<AddTaskModal> {
  late final TextEditingController _title;
  late final TextEditingController _discipline;
  late final TextEditingController _date;
  late TaskPriority _priority;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _title = TextEditingController(text: existing?.title ?? '');
    _discipline = TextEditingController(text: existing?.discipline ?? '');
    _date = TextEditingController(text: existing == null ? '' : DateFormatters.input(existing.dueDate));
    _priority = existing?.priority ?? TaskPriority.media;
  }

  @override
  void dispose() {
    _title.dispose();
    _discipline.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final parsed = DateFormatters.tryParseInput(_date.text) ?? widget.store.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _date.text = DateFormatters.input(picked);
      setState(() {});
    }
  }

  Future<void> _pickDiscipline() async {
    final known = <String>{
      ..._defaultDisciplines,
      ...widget.store.deliveries.map((item) => item.discipline).where((item) => item.trim().isNotEmpty),
    }.toList()
      ..sort();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DisciplinePicker(options: known, current: _discipline.text),
    );
    if (selected != null) {
      _discipline.text = selected;
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final discipline = _discipline.text.trim();
    final date = DateFormatters.tryParseInput(_date.text);
    if (title.isEmpty || discipline.isEmpty || date == null) {
      setState(() => _error = 'Preencha título, disciplina e a data no formato DD/MM/AAAA.');
      return;
    }
    final existing = widget.existing;
    if (existing == null) {
      await widget.store.addDelivery(
        Delivery(
          id: const Uuid().v4(),
          title: title,
          discipline: discipline,
          dueDate: date,
          priority: _priority,
        ),
      );
    } else {
      await widget.store.updateDelivery(
        existing.copyWith(
          title: title,
          discipline: discipline,
          dueDate: date,
          priority: _priority,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppColors.handle,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Text(
                    widget.existing == null ? 'Nova Entrega' : 'Editar Entrega',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _label('O que você precisa entregar?'),
                  CustomInput(controller: _title, hint: 'Ex: Checkpoint 2, GS...'),
                  const SizedBox(height: 14),
                  _label('Disciplina'),
                  CustomInput(
                    controller: _discipline,
                    hint: 'Selecione uma disciplina',
                    readOnly: true,
                    onTap: _pickDiscipline,
                    suffix: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _label('Data Limite'),
                  CustomInput(
                    controller: _date,
                    hint: 'DD/MM/AAAA',
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    onTap: _pickDate,
                    suffix: const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 18),
                  ),
                  const SizedBox(height: 16),
                  _label('Peso da Tarefa'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final priority in TaskPriority.values) ...[
                        Expanded(child: _priorityChip(priority)),
                        if (priority != TaskPriority.alta) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.high, fontSize: 12, fontFamily: 'Poppins')),
                  ],
                  const SizedBox(height: 22),
                  CustomButton(
                    label: widget.existing == null ? 'Criar Rota' : 'Salvar alterações',
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _priorityChip(TaskPriority priority) {
    final selected = _priority == priority;
    return GestureDetector(
      onTap: () => setState(() => _priority = priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? priority.color : priority.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: priority.color.withValues(alpha: selected ? 0 : 0.45)),
        ),
        child: Text(
          priority.label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? AppColors.background : priority.color,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet com a lista de disciplinas conhecidas + opção de digitar uma nova.
class _DisciplinePicker extends StatefulWidget {
  const _DisciplinePicker({required this.options, required this.current});

  final List<String> options;
  final String current;

  @override
  State<_DisciplinePicker> createState() => _DisciplinePickerState();
}

class _DisciplinePickerState extends State<_DisciplinePicker> {
  bool _customMode = false;
  late final TextEditingController _custom = TextEditingController(
    text: widget.options.contains(widget.current) ? '' : widget.current,
  );

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.handle,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const Text(
                'Disciplina',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 14),
              if (!_customMode) ...[
                for (final option in widget.options) _optionTile(option),
                _addNewTile(),
              ] else ...[
                Text(
                  'Nome da disciplina',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                CustomInput(controller: _custom, hint: 'Ex: Cross-Platform, Java...'),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Usar esta disciplina',
                  onPressed: () {
                    final value = _custom.text.trim();
                    if (value.isEmpty) return;
                    Navigator.of(context).pop(value);
                  },
                ),
                const SizedBox(height: 8),
                CustomButton(
                  label: 'Voltar para a lista',
                  tone: CustomButtonTone.ghost,
                  onPressed: () => setState(() => _customMode = false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(String option) {
    final selected = option == widget.current;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pop(option),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.14) : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _addNewTile() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _customMode = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 18),
            SizedBox(width: 8),
            Text(
              'Outra disciplina',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
