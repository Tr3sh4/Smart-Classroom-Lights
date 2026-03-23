import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/light_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LightProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inactivity Timer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${provider.inactivitySeconds} seconds'),
                      Slider(
                        value: provider.inactivitySeconds.toDouble(),
                        min: 10,
                        max: 300,
                        divisions: 29,
                        label: '${provider.inactivitySeconds}s',
                        onChanged: (_) {},
                        onChangeEnd: (value) {
                          provider.setInactivitySeconds(value.toInt());
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Energy Cost',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱${provider.totalCostSaved.toStringAsFixed(1)} saved',
                      ),
                      Slider(
                        value: provider.costPerKwh,
                        min: 5,
                        max: 25,
                        divisions: 20,
                        label: '₱${provider.costPerKwh.toStringAsFixed(1)}',
                        onChanged: (_) {},
                        onChangeEnd: (value) {
                          provider.setCostPerKwh(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Motion sensor simulation enabled in auto mode.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}
