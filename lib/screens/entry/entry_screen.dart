import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../services/ocr_service.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _gender;
  DateTime? _birthday;
  bool _saving = false;
  bool _recognizing = false;

  // OCR 识别后高亮哪些字段，以及哪些字段置信度低
  final Set<String> _ocrHighlighted = {};
  final Set<String> _ocrLowConfidence = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _pointsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndRecognize() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.camera);
    if (xfile == null) return;

    setState(() => _recognizing = true);
    try {
      final fields = await OcrService().recognizeImage(File(xfile.path));
      setState(() {
        _ocrHighlighted.clear();
        _ocrLowConfidence.clear();
        for (final f in fields) {
          final low = f.confidence < 0.7;
          switch (f.key) {
            case 'name':
              _nameCtrl.text = f.value;
              _ocrHighlighted.add('name');
              if (low) _ocrLowConfidence.add('name');
            case 'clothing_size':
              _sizeCtrl.text = f.value;
              _ocrHighlighted.add('size');
              if (low) _ocrLowConfidence.add('size');
            case 'points':
              _pointsCtrl.text = f.value;
              _ocrHighlighted.add('points');
              if (low) _ocrLowConfidence.add('points');
            case 'phone':
              _phoneCtrl.text = f.value;
              _ocrHighlighted.add('phone');
              if (low) _ocrLowConfidence.add('phone');
            case 'birthday':
              try {
                _birthday = DateTime.parse(f.value);
                _ocrHighlighted.add('birthday');
                if (low) _ocrLowConfidence.add('birthday');
              } catch (_) {}
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('识别失败: $e')),
        );
      }
    } finally {
      setState(() => _recognizing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final customer = Customer(
        name: _nameCtrl.text.trim(),
        clothingSize: _sizeCtrl.text.trim(),
        points: int.parse(_pointsCtrl.text.trim()),
        gender: _gender,
        birthday: _birthday,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        storeId: AppConfig.defaultStoreId,
      );
      await context.read<CustomerProvider>().addCustomer(customer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _gender = null;
          _birthday = null;
          _ocrHighlighted.clear();
          _ocrLowConfidence.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Color? _fieldFill(String key) =>
      _ocrHighlighted.contains(key) ? Colors.yellow[100] : null;

  Widget _lowConfidenceIcon(String key) => _ocrLowConfidence.contains(key)
      ? const Tooltip(
          message: '识别置信度低，请核对',
          child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
        )
      : const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增顾客')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 姓名（必填）
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: '姓名 *',
                      filled: _ocrHighlighted.contains('name'),
                      fillColor: _fieldFill('name'),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '姓名不能为空' : null,
                  ),
                ),
                _lowConfidenceIcon('name'),
              ]),
              const SizedBox(height: 12),
              // 衣服型号（必填）
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeCtrl,
                    decoration: InputDecoration(
                      labelText: '衣服型号 *',
                      filled: _ocrHighlighted.contains('size'),
                      fillColor: _fieldFill('size'),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '型号不能为空' : null,
                  ),
                ),
                _lowConfidenceIcon('size'),
              ]),
              const SizedBox(height: 12),
              // 积分（必填）
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _pointsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '积分 *',
                      filled: _ocrHighlighted.contains('points'),
                      fillColor: _fieldFill('points'),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '积分不能为空';
                      if (int.tryParse(v.trim()) == null) return '请输入整数';
                      return null;
                    },
                  ),
                ),
                _lowConfidenceIcon('points'),
              ]),
              const SizedBox(height: 12),
              // 性别（选填）
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: '性别（选填）'),
                items: ['男', '女', '其他']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              // 生日（选填）
              Row(children: [
                Expanded(
                  child: InkWell(
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
                      decoration: InputDecoration(
                        labelText: '生日（选填）',
                        filled: _ocrHighlighted.contains('birthday'),
                        fillColor: _fieldFill('birthday'),
                      ),
                      child: Text(
                        _birthday != null
                            ? DateFormat('yyyy-MM-dd').format(_birthday!)
                            : '点击选择',
                        style: TextStyle(
                          color: _birthday != null
                              ? null
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                ),
                _lowConfidenceIcon('birthday'),
              ]),
              const SizedBox(height: 12),
              // 手机号（选填）
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: '手机号（选填）',
                      filled: _ocrHighlighted.contains('phone'),
                      fillColor: _fieldFill('phone'),
                    ),
                  ),
                ),
                _lowConfidenceIcon('phone'),
              ]),
              const SizedBox(height: 24),
              // 拍照识别按钮
              OutlinedButton.icon(
                onPressed: _recognizing ? null : _pickAndRecognize,
                icon: _recognizing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(_recognizing ? '识别中...' : '📷 拍照识别'),
              ),
              const SizedBox(height: 12),
              // 保存按钮
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
