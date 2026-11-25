import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_application/controllers/text_changes_controller.dart';
import 'package:test_application/pages/widgets/custom_text_field.dart';
import 'package:test_application/res/values.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   
    final controller = Get.put(TextChangesController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
            color: Colors.white,
            width: Get.width,
            height: Get.height,
            child: SingleChildScrollView(
              child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: Get.width*(15/mainWidth)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     SizedBox(
                      height: Get.height * (50 / mainHeight),
                    ),
                   Center(
                      child: Text('Words Analyzer',style: TextStyle(fontSize: 20),),
                    )
                  ,
                    SizedBox(
                      height: Get.height * (50 / mainHeight),
                    ),
                      CustomTextField(controller: controller),
                             SizedBox(height: 12),
                            Obx(
                () => controller.isAnalyzing.value
                    ?  LinearProgressIndicator()
                    :  SizedBox(height: Get.height * (5 / mainHeight)),
                            ),
                             SizedBox(height: Get.height * (10 / mainHeight)),
                            Container(
                child: Obx(() {
                  if (controller.hasError.value) {
                    return  Center(
                      child: Text('Analysis failed. Please try again.'),
                    );
                  }
                
                  return Column(
                    children: [
                      Text('Words Count: ${controller.wordCount.value}'),
                       SizedBox(height: Get.height * (5 / mainHeight)),
                      Text('Letters Count: ${controller.letterCount.value}'),
                     SizedBox(height: Get.height * (5 / mainHeight)),
                      SizedBox(height: Get.height * (5 / mainHeight)),
                      Text('Whitespaces Count: ${controller.whitespaceCount.value}'),
                    SizedBox(height: Get.height * (5 / mainHeight)),
                       Text(
                        'Top 5 words:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                     SizedBox(height: Get.height * (5 / mainHeight)),
                      ...controller.topWords.map(
                        (item) => Padding(
                          padding:  EdgeInsets.symmetric(vertical: Get.height * (5 / mainHeight)),
                          child: Text('${item.word}: ${item.count}'),
                        ),
                      ),
                    ],
                  );
                 //textfield
                            
                 //result card
                   })) ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}