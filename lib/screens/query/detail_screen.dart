import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';

class DetailScreen extends StatefulWidget {
  final Customer customer;

  const DetailScreen({super.key, required this.customer});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _editing;
  late TextEditingController _nameCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _pointsCtrl;
  late TextEditingController _phoneCtrl;
  String? _gender;
  DateTime? _birthday;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _editing = false;
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: c.name);
    _sizeCtrl = TextEditingController(text: c.clothingSize);
    _pointsCtrl = TextEditingController(text: c.points.toString());
    _phoneCtrl = TextEditingController(text: c.phone ?? '');
    _gender = c.gender;
    _birthday = c.birthday;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _pointsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    setState(() => _saving = true);
    try {
      final updated = widget.customer.copyWith(
        name: _nameCtrl.text.trim(),
        clothingSize: _sizeCtrl.text.trim(),
        points: int.parse(_pointsCtrl.text.trim()),
        gender: _gender,
        birthday: _birthday,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      await context.read<CustomerProvider>().updateCustomer(updated);
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            Expanded(child: Text(value.isEmpty ? '—' : value)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? '编辑顾客' : '顾客详情'),
        actions: [
          if (!_editing)
            TextButton(
              onPressed: () => setState(() => _editing = true),
              child: const Text('编辑'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _editing ? _buildEditForm() : _buildDetail(c),
      ),
    );
  }

  Widget _buildDetail(Customer c) {
    final fmt = DateFormat('yyyy-MM-dd');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('姓名', c.name),
        _field('衣服型号', c.clothingSize),
        _field('积分', '${c.points} 分'),
        _field('性别', c.gender ?? ''),
        _field('生日', c.birthday != null ? fmt.format(c.birthday!) : ''),
        _field('手机号', c.phone ?? ''),
        _field('门店 ID', c.storeId.toString()),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: '姓名 *'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _sizeCtrl,
          decoration: const InputDecoration(labelText: '衣服型号 *'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pointsCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '积分 *'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(labelText: '性别（选填）'),
          items: ['男', '女', '其他']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _gender = v),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthday ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _birthday = picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: '生日（选填）'),
            child: Text(
              _birthday != null
                  ? DateFormat('yyyy-MM-dd').format(_birthday!)
                  : '点击选择',
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: '手机号（选填）'),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _saving ? null : _saveEdit,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('取消'),
            ),
          ),
        ]),
      ],
    );
  }
}
