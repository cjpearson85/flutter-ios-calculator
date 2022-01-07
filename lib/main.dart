import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Calculator();
  }
}

class Calculator extends StatefulWidget {
  const Calculator({ Key? key }) : super(key: key);

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  List<String> _formula = [''];

  void insertNum(String number) {
    if ((_formula[_formula.length - 1] != '' || number != '0') && _formula[_formula.length - 1].length < 9) {
      setState(() {
        _formula[_formula.length - 1] += number;
      });
    }
  }

  void insertDecimalPoint() {
    if (!_formula[_formula.length - 1].contains('.')) {
      setState(() {
        if (_formula[_formula.length - 1] != '') {
          _formula[_formula.length - 1] += '.';
        } else {
          _formula[_formula.length - 1] += '0.';
        }
      });
    }
  }

  void insertOperator(String symbol) {
    if (_formula[_formula.length - 1] != '') {
      if (
        _formula.length > 2 &&
        (["+", "-"].contains(symbol) || 
        (["*", "/"].contains(_formula[_formula.length - 2]) && 
        ["*", "/"].contains(symbol)))
      ) {
        var result = performCalc(_formula.sublist(_formula.length - 3));
        setState(() {
          _formula = [..._formula.sublist(0, _formula.length - 3), ...result];
        });
      }
      setState(() {
        _formula.addAll([symbol, '']);
      });
    } else {
      setState(() {
        _formula[_formula.length - 2] = symbol;
      });
    }
  }

  void toggleNegative() {
    if (_formula[_formula.length - 1].startsWith('-')) {
      setState(() {
        _formula[_formula.length - 1] = _formula[_formula.length - 1].substring(1);
      });
    } else {
      setState(() {
        _formula[_formula.length - 1] = '-' + _formula[_formula.length - 1];
      });
    }
  }

  void percentage() {
    if (['+', '-'].contains(_formula[_formula.length - 2])) {
        setState(() {
          _formula[_formula.length - 1] = (num.parse(_formula[_formula.length - 3]) * num.parse(_formula[_formula.length - 1]) / 100).toString();
        });
    } else if (['*', '/'].contains(_formula[_formula.length - 2])) {
        setState(() {
          _formula[_formula.length - 1] = (num.parse(_formula[_formula.length - 1]) / 100).toString();
        });
    }
  }

  void clearDisplay(String status) {
    if (status == 'AC') {
      setState(() {
        _formula = [''];
      });
    } else {
      setState(() {
        _formula[_formula.length - 1] = '';
      });
    }
  }

  void complete() {
    if (_formula[_formula.length - 1] == '') {
      _formula[_formula.length - 1] = _formula[_formula.length - 3];
    }

    setState(() {
      _formula = performCalc(_formula);
    });
  }

  performCalc(List<String> arr) {
    if (arr.length == 1) {
      return arr;
    }

    num multiplyIndex = arr.contains('*') ? arr.indexOf('*') : double.infinity;
    num divideIndex = arr.contains('/') ? arr.indexOf('/') : double.infinity;

    if (multiplyIndex != double.infinity || divideIndex != double.infinity) {
      if (multiplyIndex < divideIndex) {
        var multiplication = num.parse(arr[multiplyIndex.toInt() - 1]) * num.parse(arr[multiplyIndex.toInt() + 1]);
        arr.replaceRange(multiplyIndex.toInt() - 1, multiplyIndex.toInt() + 2, [multiplication.toString()]);
      } else {
        var division = num.parse(arr[divideIndex.toInt() - 1]) / num.parse(arr[divideIndex.toInt() + 1]);
        arr.replaceRange(divideIndex.toInt() - 1, divideIndex.toInt() + 2, [division.toString()]);
      }
      return performCalc(arr);
    }

    num plusIndex = arr.contains('+') ? arr.indexOf('+') : double.infinity;
    num subtractIndex = arr.contains('-') ? arr.indexOf('-') : double.infinity;

    if (plusIndex != subtractIndex) {
      if (plusIndex < subtractIndex) {
        var addition = num.parse(arr[plusIndex.toInt() - 1]) + num.parse(arr[plusIndex.toInt() + 1]);
        arr.replaceRange(plusIndex.toInt() - 1, plusIndex.toInt() + 2, [addition.toString()]);
      } else {
        var subtraction = num.parse(arr[subtractIndex.toInt() - 1]) - num.parse(arr[subtractIndex.toInt() + 1]);
        arr.replaceRange(subtractIndex.toInt() - 1, subtractIndex.toInt() + 2, [subtraction.toString()]);
      }
      return performCalc(arr);
    }

    return ['Error'];
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,                
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 70.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.all(10),
                //   child: Text(
                //     _formula.join(' '),
                //     maxLines: 1,
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formula[_formula.length - 1] == '' && _formula.length == 1 ? '0' : _formula[_formula.length - 1] == '' && _formula.length > 1 ? _formula[_formula.length - 3] : _formula[_formula.length - 1].length < 10 ? _formula[_formula.length - 1] : num.parse(_formula[_formula.length - 1]).toStringAsPrecision(6),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 90,
                      ),
                    ),
                  ),
                ),
                GridView.count(
                  primary: false,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  children: <Widget>[
                    _formula[_formula.length - 1] == '' ? CustomButton(label: 'AC', onPress: () => clearDisplay('AC'), type: 'top') : CustomButton(label: 'C', onPress: () => clearDisplay('C'), type: 'top'),
                    CustomButton(label: '+/-', onPress: toggleNegative, type: 'top'),
                    CustomButton(label: '%', onPress: percentage, type: 'top'),
                    CustomButton(label: '÷', onPress: () => insertOperator('/'), type: _formula[_formula.length - 1] == '' && _formula.length > 1 && _formula[_formula.length - 2] == '/' ? 'active' : 'operator'),
                    CustomButton(label: '7', onPress: () => insertNum('7'), type: 'number'),
                    CustomButton(label: '8', onPress: () => insertNum('8'), type: 'number'),
                    CustomButton(label: '9', onPress: () => insertNum('9'), type: 'number'),
                    CustomButton(label: 'x', onPress: () => insertOperator('*'), type: _formula[_formula.length - 1] == '' && _formula.length > 1 && _formula[_formula.length - 2] == '*' ? 'active' : 'operator'),
                    CustomButton(label: '4', onPress: () => insertNum('4'), type: 'number'),
                    CustomButton(label: '5', onPress: () => insertNum('5'), type: 'number'),
                    CustomButton(label: '6', onPress: () => insertNum('6'), type: 'number'),
                    CustomButton(label: '-', onPress: () => insertOperator('-'), type: _formula[_formula.length - 1] == '' && _formula.length > 1 && _formula[_formula.length - 2] == '-' ? 'active' : 'operator'),
                    CustomButton(label: '1', onPress: () => insertNum('1'), type: 'number'),
                    CustomButton(label: '2', onPress: () => insertNum('2'), type: 'number'),
                    CustomButton(label: '3', onPress: () => insertNum('3'), type: 'number'),
                    CustomButton(label: '+', onPress: () => insertOperator('+'), type: _formula[_formula.length - 1] == '' && _formula.length > 1 && _formula[_formula.length - 2] == '+' ? 'active' : 'operator'),
                    Container(),
                    CustomButton(label: '0', onPress: () => insertNum('0'), type: 'number'),
                    CustomButton(label: '.', onPress: insertDecimalPoint, type: 'number'),
                    CustomButton(label: '=', onPress: complete, type: 'operator'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({required this.label, required this.onPress, required this.type, Key? key}) : super(key: key);

  final String label;
  final VoidCallback onPress;
  final String type;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(type == 'active' ? Colors.white : type == 'operator' ? Colors.orange : type == 'top' ? Colors.grey : Colors.grey.shade800),
        foregroundColor: MaterialStateProperty.all<Color>(type == 'active' ? Colors.orange : type == 'top' ? Colors.black : Colors.white),
        shape: MaterialStateProperty.all(const CircleBorder()),
        padding: MaterialStateProperty.all(type == 'operator' || type == 'active' ? const EdgeInsets.only(bottom: 5.0) : null),
      ),
      onPressed: onPress,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontWeight: type == 'top' ? FontWeight.w500 : FontWeight.w400,
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
