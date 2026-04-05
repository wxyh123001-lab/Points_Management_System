import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/customer_list_tile.dart';
import 'detail_screen.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  bool _filterExpanded = false;
  int? _selectedPointsPreset; // 500 / 800 / 1000
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  int? _selectedBirthMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    int? minPoints;
    int? maxPoints;

    if (_selectedPointsPreset != null) {
      minPoints = _selectedPointsPreset;
    } else {
      minPoints = int.tryParse(_minCtrl.text);
      maxPoints = int.tryParse(_maxCtrl.text);
    }

    context.read<CustomerProvider>().setFilter(
          CustomerFilter(
            minPoints: minPoints,
            maxPoints: maxPoints,
            birthMonth: _selectedBirthMonth,
          ),
        );
    setState(() => _filterExpanded = false);
  }

  void _clearFilter() {
    _minCtrl.clear();
    _maxCtrl.clear();
    setState(() {
      _selectedPointsPreset = null;
      _selectedBirthMonth = null;
    });
    context.read<CustomerProvider>().setFilter(const CustomerFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('顾客查询'),
        actions: [
          IconButton(
            icon: Icon(_filterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _filterExpanded = !_filterExpanded),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          if (_filterExpanded)
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('积分筛选', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('全部'),
                          selected: _selectedPointsPreset == null && _minCtrl.text.isEmpty,
                          onSelected: (_) => setState(() => _selectedPointsPreset = null),
                        ),
                        for (final pts in [500, 800, 1000])
                          ChoiceChip(
                            label: Text('≥ $pts'),
                            selected: _selectedPointsPreset == pts,
                            onSelected: (_) =>
                                setState(() => _selectedPointsPreset = pts),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '最低积分',
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() => _selectedPointsPreset = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '最高积分',
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() => _selectedPointsPreset = null),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    const Text('生日筛选', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<int?>(
                      value: _selectedBirthMonth,
                      hint: const Text('全部月份'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('全部'),
                        ),
                        DropdownMenuItem<int?>(
                          value: DateTime.now().month,
                          child: const Text('本月'),
                        ),
                        for (int m = 1; m <= 12; m++)
                          DropdownMenuItem<int?>(
                            value: m,
                            child: Text('$m 月'),
                          ),
                      ],
                      onChanged: (v) => setState(() => _selectedBirthMonth = v),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      ElevatedButton(
                        onPressed: _applyFilter,
                        child: const Text('应用筛选'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _clearFilter,
                        child: const Text('清除'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          // 顾客列表
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('加载失败: ${provider.error}'),
                        TextButton(
                          onPressed: provider.loadCustomers,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }
                if (provider.customers.isEmpty) {
                  return const Center(child: Text('暂无顾客记录'));
                }
                return ListView.separated(
                  itemCount: provider.customers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final c = provider.customers[idx];
                    return CustomerListTile(
                      customer: c,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(customer: c),
                        ),
                      ).then((_) => provider.loadCustomers()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
