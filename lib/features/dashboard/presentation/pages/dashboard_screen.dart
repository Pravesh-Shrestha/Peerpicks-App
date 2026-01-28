import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Personalized Header with Profile Picture
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user?.profilePicture != null
                        ? NetworkImage(
                            "${ApiEndpoints.baseUrl.replaceAll('//', '/')}${user!.profilePicture}",
                          )
                        : null,
                    child: user?.profilePicture == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        user?.fullName.split(' ')[0] ?? "Probs",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 2. Logo Integration
              Image.asset(
                '/assets/images/logos/logo.png', // Replace with your actual asset path
                height: 50,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "PEERPICKS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const Icon(Icons.search, color: Colors.black, size: 28),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFC5FF41), // Matching Lime Green
            indicatorWeight: 3,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: "Popular"),
              Tab(text: "For You"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildPopularTab(), _buildForYouTab()]),
      ),
    );
  }

  // --- POPULAR TAB SECTION ---
  Widget _buildPopularTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Category Moving Carousel with Skeletons
          CarouselSlider.builder(
            itemCount: 3,
            options: CarouselOptions(
              height: 180,
              enlargeCenterPage: true,
              autoPlay: true,
              viewportFraction: 0.85,
            ),
            itemBuilder: (context, index, realIdx) {
              return _buildSkeletonCard(width: double.infinity, height: 180);
            },
          ),
          _sectionHeader("Most Visited Places"),
          _buildHorizontalSkeletonList(),
          _sectionHeader("Most Rated Places"),
          _buildHorizontalSkeletonList(),
          const SizedBox(height: 100), // Padding for Bottom Bar
        ],
      ),
    );
  }

  // --- FOR YOU TAB SECTION ---
  Widget _buildForYouTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => _buildReviewSkeleton(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "View more ->",
            style: TextStyle(color: Colors.blueAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSkeletonList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) => _buildPlaceSkeleton(),
      ),
    );
  }

  Widget _buildPlaceSkeleton() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 12, width: 100, color: Colors.grey[200]),
          const SizedBox(height: 4),
          Container(height: 10, width: 60, color: Colors.grey[100]),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildReviewSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC5FF41).withOpacity(0.2), // Faded Lime
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFC5FF41)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey[300], radius: 18),
              const SizedBox(width: 10),
              Container(height: 12, width: 100, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(child: Text("Review Loading...")),
          ),
        ],
      ),
    );
  }
}
