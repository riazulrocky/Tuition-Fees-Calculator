import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TuitionCalculator extends StatefulWidget {
  const TuitionCalculator({super.key});

  @override
  _TuitionCalculatorState createState() => _TuitionCalculatorState();
}

class _TuitionCalculatorState extends State<TuitionCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _semesterFeesController = TextEditingController();
  final TextEditingController _perCreditFeesController = TextEditingController();
  final TextEditingController _totalCreditsController = TextEditingController();
  final TextEditingController _waiverPercentageController = TextEditingController();

  // Results variables
  double? _creditCost;
  double? _waiverAmount;
  double? _totalCost;
  double? _firstInstallment;
  double? _secondInstallment;
  double? _thirdInstallment;
  double? _totalWithFine;
  bool _showResults = false;

  void _calculateFees() {
    if (!_formKey.currentState!.validate()) return;

    final semesterFees = double.tryParse(_semesterFeesController.text) ?? 0;
    final perCreditFees = double.tryParse(_perCreditFeesController.text) ?? 0;
    final totalCredits = double.tryParse(_totalCreditsController.text) ?? 0;
    final waiverPercentage = double.tryParse(_waiverPercentageController.text) ?? 0;

    if (perCreditFees <= 0 || totalCredits <= 0) {
      _showSnackBar('Please enter valid values for per credit fees and total credits', Colors.red);
      return;
    }

    setState(() {
      _creditCost = perCreditFees * totalCredits;
      _waiverAmount = (_creditCost! * waiverPercentage) / 100;
      _totalCost = _creditCost! - _waiverAmount! + semesterFees;

      _firstInstallment = (_totalCost! * 40) / 100;
      _secondInstallment = (_totalCost! * 30) / 100;
      _thirdInstallment = (_totalCost! * 30) / 100;
      _totalWithFine = _totalCost! + 1000;

      _showResults = true;
    });

    _showSnackBar('Fees calculated successfully!', Colors.green);
  }

  void _resetCalculator() {
    setState(() {
      _semesterFeesController.clear();
      _perCreditFeesController.clear();
      _totalCreditsController.clear();
      _waiverPercentageController.clear();
      _showResults = false;
    });
    _showSnackBar('Calculator reset', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.indigo.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 2),
                _buildInputForm(),
                if (_showResults) ...[
                  SizedBox(height: 24),
                  _buildResultsSection(),
                  SizedBox(height: 16),
                  _buildFineWarning(),
                ],
                SizedBox(height: 24),
                _buildDeveloperCredit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 28, color: Colors.blue.shade600),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Tuition Fees Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: Colors.blue.shade600),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Fee Calculation Form',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildResponsiveInputs(),
              SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveInputs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop/Tablet layout - 2 columns
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildInputField('Semester Registration Fees (৳)', _semesterFeesController)),
                  SizedBox(width: 16),
                  Expanded(child: _buildInputField('Per Credit Fees (৳)', _perCreditFeesController, required: true)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField('Total Credits', _totalCreditsController, required: true)),
                  SizedBox(width: 16),
                  Expanded(child: _buildInputField('Waiver Percentage (%)', _waiverPercentageController, maxValue: 100)),
                ],
              ),
            ],
          );
        } else {
          // Mobile layout - single column
          return Column(
            children: [
              _buildInputField('Semester Registration Fees (৳)', _semesterFeesController),
              SizedBox(height: 16),
              _buildInputField('Per Credit Fees (৳)', _perCreditFeesController, required: true),
              SizedBox(height: 16),
              _buildInputField('Total Credits', _totalCreditsController, required: true),
              SizedBox(height: 16),
              _buildInputField('Waiver Percentage (%)', _waiverPercentageController, maxValue: 100),
            ],
          );
        }
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool required = false, double? maxValue}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (maxValue != null && value != null && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue != null && numValue > maxValue) {
            return 'Value cannot exceed $maxValue';
          }
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 400) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculateFees,
                  icon: Icon(Icons.calculate),
                  label: Text('Calculate Fees'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetCalculator,
                  child: Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculateFees,
                  icon: Icon(Icons.calculate),
                  label: Text('Calculate Fees'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetCalculator,
                  child: Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildResultsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCostBreakdown()),
              SizedBox(width: 16),
              Expanded(child: _buildPaymentInstallments()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildCostBreakdown(),
              SizedBox(height: 16),
              _buildPaymentInstallments(),
            ],
          );
        }
      },
    );
  }

  Widget _buildCostBreakdown() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildCostRow('Credit Cost:', '৳${_creditCost!.toStringAsFixed(0)}'),
            _buildCostRow('Waiver Amount:', '-৳${_waiverAmount!.toStringAsFixed(0)}', color: Colors.green.shade600),
            _buildCostRow('Registration Fees:', '৳${double.tryParse(_semesterFeesController.text)?.toStringAsFixed(0) ?? '0'}'),
            Divider(thickness: 2),
            _buildCostRow('Total Cost:', '৳${_totalCost!.toStringAsFixed(0)}',
                isTotal: true, color: Colors.blue.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstallments() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Installments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildInstallmentCard('1st Installment (40%)', _firstInstallment!, Colors.blue),
            SizedBox(height: 12),
            _buildInstallmentCard('2nd Installment (30%)', _secondInstallment!, Colors.orange),
            SizedBox(height: 12),
            _buildInstallmentCard('3rd Installment (30%)', _thirdInstallment!, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentCard(String title, double amount, MaterialColor cardColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardColor.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cardColor.shade800,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '৳${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cardColor.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFineWarning() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade600, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Late Payment Fine',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'If payment is not completed within the semester, a fine of ৳1,000 will be added.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Total with Fine:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '৳${_totalWithFine!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCredit() {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade500, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Developed by',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Riazul Hasan Rocky',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _semesterFeesController.dispose();
    _perCreditFeesController.dispose();
    _totalCreditsController.dispose();
    _waiverPercentageController.dispose();
    super.dispose();
  }
}
