import 'package:flutter/material.dart';
import 'package:stock_valuation_app/features/valuation/domain/valuation_models.dart';

class ValuationCard extends StatelessWidget {
  final ValuationResult result;

  const ValuationCard({super.key, required this.result});

  Color _getVerdictColor(String verdict) {
    switch (verdict) {
      case 'STRONG BUY': return const Color(0xFF10B981); // Emerald
      case 'BUY': return const Color(0xFF34D399);
      case 'HOLD': return const Color(0xFFFBBF24); // Amber
      case 'SELL': return const Color(0xFFF87171);
      case 'STRONG SELL': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getVerdictColor(result.verdict);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fair Value Analysis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    result.verdict,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueColumn(context, 'Fair Value', '\$${result.fairValue.toStringAsFixed(2)}'),
                _buildValueColumn(context, 'Upside', '${result.upside >= 0 ? '+' : ''}${result.upside.toStringAsFixed(1)}%', 
                  color: result.upside >= 0 ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('DCF Model', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 4),
            if (result.dcf != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Intrisic Value (DCF)', style: const TextStyle(fontSize: 13)),
                  Text('\$${result.dcf!.fairValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            else
              const Text('Data unavailable for DCF', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildValueColumn(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
