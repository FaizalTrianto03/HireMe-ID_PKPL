import 'package:HireMe_Id/recruiter/home/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class HomeViewRecruiter extends StatelessWidget {
  final HomeControllerRecruiter controller = Get.put(HomeControllerRecruiter());
  @override
  Widget build(BuildContext context) {
    controller.fetchHomeData();
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: 'RedHatDisplay',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        // Count applications "Pending Review"
        final ReviewCount = controller.allApplications.where((application) {
          return application['status'] == 'Review';
        }).length;
        final AcceptedCount = controller.allApplications.where((application) {
          return application['status'] == 'Diterima';
        }).length;
        final RejectedCount = controller.allApplications.where((application) {
          return application['status'] == 'Ditolak';
        }).length;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Normal Header Section
              headerWidget(controller.recruiterName.value, controller.companyName.value),
              SizedBox(height: 16),
              // Jobs Stats Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Jobs',
                        '${controller.jobCount.value}',
                        Color(0xFF6B34BE),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Active Jobs',
                        '${controller.jobCount.value}',  // You might want to add this to your controller
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              // Applicants Overview Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applicants Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'RedHatDisplay',
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildApplicantsPieChart(ReviewCount, AcceptedCount, RejectedCount),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildApplicantStatRow('Total Applicants', controller.allApplications.length.toString(), Colors.purple),
                          Divider(height: 1),
                          _buildApplicantStatRow('Pending Review', ReviewCount.toString(), Colors.orange),
                          Divider(height: 1),
                          _buildApplicantStatRow('Accepted', AcceptedCount.toString(), Colors.blue),
                          Divider(height: 1),
                          _buildApplicantStatRow('Rejected', RejectedCount.toString(), Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer Message
              
            ],
          ),
        );
      }),
    );
  }
 Widget headerWidget(String? recruiterName, String? companyName) {
  bool isDataIncomplete = recruiterName == null || recruiterName.isEmpty || companyName == null || companyName.isEmpty;
  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDataIncomplete) ...[
          Text(
            'Hi, $recruiterName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'RedHatDisplay',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Company: $companyName',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'RedHatDisplay',
            ),
          ),
        ],
        if (isDataIncomplete)
          Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.yellow[700]!,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.yellow[800]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Harap melengkapi detail informasi di menu pengaturan profile.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'RedHatDisplay',
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'RedHatDisplay',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildApplicantStatRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontFamily: 'RedHatDisplay',
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'RedHatDisplay',
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildApplicantsPieChart(int reviewCount, int acceptedCount, int rejectedCount) {
  // Validasi jika semua data kosong
  if (reviewCount == 0 && acceptedCount == 0 && rejectedCount == 0) {
    return Center(
      child: Text(
        'No data available for chart.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  return Container(
    height: 200,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: reviewCount.toDouble(),
            color: Colors.orange,
            title: reviewCount > 0 ? '$reviewCount' : '',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: acceptedCount.toDouble(),
            color: Colors.blue,
            title: acceptedCount > 0 ? '$acceptedCount' : '',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: rejectedCount.toDouble(),
            color: Colors.red,
            title: rejectedCount > 0 ? '$rejectedCount' : '',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    ),
  );
}

}

