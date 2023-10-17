import 'package:fitnessco/utils/color_utils.dart';
import 'package:fitnessco/utils/firebase_util.dart';
import 'package:fitnessco/widgets/custom_container_widget.dart';
import 'package:fitnessco/widgets/custom_text_widgets.dart';
import 'package:fitnessco/widgets/fitnessco_textfield_widget.dart';
import 'package:flutter/material.dart';

import '../utils/pop_up_util.dart';

class BMIHistoryScreen extends StatefulWidget {
  const BMIHistoryScreen({super.key});

  @override
  State<BMIHistoryScreen> createState() => _BMIHistoryScreenState();
}

class _BMIHistoryScreenState extends State<BMIHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> bmiHistory = [];
  double latestBMI = 0;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getBMIHistory();
  }

  @override
  void dispose() {
    super.dispose();
    _heightController.dispose();
    _weightController.dispose();
  }

  void _getBMIHistory() async {
    try {
      //  First we get the current client's data from Firebase
      final currentUserData = await getCurrentUserData();

      _heightController.text =
          currentUserData['profileDetails']['height'].toString();
      _weightController.text =
          currentUserData['profileDetails']['weight'].toString();

      //  if there is no BMI History parameter, we manually add it on the fly
      if (!currentUserData.containsKey('bmiHistory')) {
        await updateCurrentUserData({'bmiHistory': []});
      } else {
        var tempList = currentUserData['bmiHistory'] as List<dynamic>;
        bmiHistory = List.from(tempList.reversed);
        latestBMI = bmiHistory.first['bmiValue'];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      showErrorMessage(context,
          label: 'Error getting BMI History: ${error.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addBMIEntry() async {
    FocusScope.of(context).unfocus();
    try {
      if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
        showErrorMessage(context,
            label: 'Please provide your height and weight.');
        return;
      }
      //  First we must check if the input is valid
      if (double.parse(_heightController.text) <= 0 ||
          double.parse(_weightController.text) <= 0) {
        showErrorMessage(context,
            label: 'The entered values must be higher than zero');
        return;
      }

      //  Set _isLoading value to true to display the loading panel
      setState(() {
        _isLoading = true;
      });
      double height = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);
      Map<String, dynamic> newBMI = {
        'dateTime': {
          'month': DateTime.now().month,
          'year': DateTime.now().year,
          'day': DateTime.now().day
        },
        'bmiValue':
            double.parse((weight / (height * height)).toStringAsFixed(2))
      };

      //  We must check if the new BMI entry is a new one or is updating an earlier inputted entry
      bool isOverwriting = false;
      List<dynamic> sequentialBMIEntries = List.from(bmiHistory.reversed);
      for (int i = 0; i < sequentialBMIEntries.length; i++) {
        if (sequentialBMIEntries[i]['dateTime']['month'] ==
                DateTime.now().month &&
            sequentialBMIEntries[i]['dateTime']['year'] ==
                DateTime.now().year &&
            sequentialBMIEntries[i]['dateTime']['day'] == DateTime.now().day) {
          isOverwriting = true;
          break;
        }
      }
      if (isOverwriting) {
        sequentialBMIEntries[bmiHistory.length - 1] = newBMI;
      } else {
        sequentialBMIEntries.add(newBMI);
      }

      //  We update the BMI history in Firebase
      await updateCurrentUserData({'bmiHistory': sequentialBMIEntries});
      showSuccessMessage(context, label: 'Successfully updated BMI History',
          onPress: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/editClientProfile');
      });

      //  Go back to the BMI History screen
    } catch (error) {
      showErrorMessage(context,
          label: 'Error adding BMI entry: ${error.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            title: Center(
                child: futuraText('Update BMI',
                    textStyle: whiteBoldStyle(size: 30)))),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: stackedLoadingContainer(context, _isLoading, [
            userAuthBackgroundContainer(context,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        _currentBMIHeader(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_newEntryInput(), _bmiChart()]),
                        ),
                        _bmiEntries()
                      ],
                    ),
                  ),
                ))
          ]),
        ));
  }

  Widget _currentBMIHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(latestBMI.toString(),
          textAlign: TextAlign.center, style: blackBoldStyle(size: 50)),
    );
  }

  Widget _newEntryInput() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35,
      height: 200,
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(children: [futuraText('Height (in M)')]),
              SizedBox(
                height: 30,
                child: fitnesscoTextField(
                    'HEIGHT IN M', TextInputType.number, _heightController),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  children: [
                    Row(children: [futuraText('Weight (in KG)')]),
                    SizedBox(
                        height: 30,
                        child: fitnesscoTextField('WEIGHT IN KG',
                            TextInputType.number, _weightController)),
                  ],
                ),
              ),
              _computeButton()
            ],
          )),
    );
  }

  Widget _bmiChart() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      child: Column(children: [
        Text('BMI Chart', style: blackBoldStyle()),
        const SizedBox(height: 10),
        roundedContainer(
            color: CustomColors.love.withOpacity(0.75),
            height: 150,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Underweight', style: blackBoldStyle()),
                          futuraText('> 18.5')
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Normal', style: blackBoldStyle()),
                        futuraText('18.5 - 24.9')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Overweight', style: blackBoldStyle()),
                        futuraText('25 - 29.9')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Obese', style: blackBoldStyle()),
                        futuraText('30 +')
                      ],
                    )
                  ],
                )))
      ]),
    );
  }

  Widget _bmiEntries() {
    return roundedContainer(
        color: CustomColors.love,
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                futuraText('My BMI History', textStyle: blackBoldStyle()),
                Column(
                    children: bmiHistory
                        .map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 252, 138, 206),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      futuraText(
                                          '${(entry['dateTime']['month']).toString()} - ${(entry['dateTime']['day']).toString()} - ${(entry['dateTime']['year']).toString()}',
                                          textStyle:
                                              TextStyle(color: Colors.white)),
                                      futuraText(
                                          'BMI: ${entry['bmiValue'].toString()}',
                                          textStyle:
                                              TextStyle(color: Colors.white))
                                    ]),
                              ),
                            ))
                        .toList())
              ],
            ),
          ),
        ));
  }

  Widget _computeButton() {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
          onPressed: _addBMIEntry,
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: futuraText('COMPUTE', textStyle: TextStyle(fontSize: 12))),
    );
  }
}
