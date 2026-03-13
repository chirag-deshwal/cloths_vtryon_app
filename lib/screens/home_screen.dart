import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  XFile? _personImage;
  XFile? _clothImage;
  String _selectedCategory = 'upper_body';
  bool _isLoading = false;
  Uint8List? _resultImage;

  // Split view ratio for adjustable screens on desktop
  double _leftPanelFlex = 0.55;

  Future<void> _pickImage(bool isPerson) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isPerson) {
          _personImage = image;
          _resultImage = null; // Clear previous result
        } else {
          _clothImage = image;
          _resultImage = null;
        }
      });
    }
  }

  Future<void> _generate() async {
    if (_personImage == null || _clothImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload both your photo and the clothing photo!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultImage = null;
    });

    final result = await _apiService.generateTryOn(
      _personImage!,
      _clothImage!,
      _selectedCategory,
    );

    setState(() {
      _isLoading = false;
      _resultImage = result;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate image. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0EFEA), // Very light beige background 
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;
            return Row(
              children: [
                // Left Sidebar (Only visible on wide screens)
                if (isDesktop) _buildSidebar(),
                
                // Main Content Area
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(isDesktop ? 16 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isDesktop ? 20 : 0),
                      boxShadow: [
                        if(isDesktop) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 10))
                      ]
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        _buildTopBar(constraints.maxWidth),
                        Divider(height: 1, color: Colors.grey[200]),
                        Expanded(
                          child: constraints.maxWidth > 800 
                              ? _buildAdjustableSplitView(constraints.maxWidth)
                              : _buildMobileScrollableLayout(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  // --- Layout Types ---

  Widget _buildAdjustableSplitView(double totalWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Panel (Product Details)
        Expanded(
          flex: (_leftPanelFlex * 100).toInt(),
          child: _buildProductDetails(isDesktop: true),
        ),
        
        // Draggable Divider
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {
              // Adjust flex based on drag, keeping it within reasonable bounds
              double deltaFlex = details.primaryDelta! / totalWidth;
              _leftPanelFlex = (_leftPanelFlex + deltaFlex).clamp(0.40, 0.70);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Container(
              width: 12,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right Panel (Try-On View)
        Expanded(
          flex: ((1 - _leftPanelFlex) * 100).toInt(),
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24, right: 24, left: 8),
            child: _buildTryOnResult(isMobile: false),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileScrollableLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTryOnResult(isMobile: true),
          ),
          _buildProductDetails(isDesktop: false),
        ],
      ),
    );
  }


  // --- UI Components ---

  Widget _buildSidebar() {
    return Container(
      width: 70,
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(height: 20),
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(height: 40),
          Icon(Icons.dry_cleaning_outlined, color: Colors.grey[400]),
          SizedBox(height: 30),
          Icon(Icons.checkroom_outlined, color: Colors.grey[400]),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFEFECE5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.accessibility_new, color: Colors.black),
          ),
          SizedBox(height: 30),
          Icon(Icons.shopping_bag_outlined, color: Colors.grey[400]),
          Spacer(),
          Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTopBar(double width) {
    bool isCompact = width < 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 30, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "M A I V E N",
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 18 : 22, 
                  fontWeight: FontWeight.w800, 
                  letterSpacing: 2
                )
              ),
              if (!isCompact) ...[
                SizedBox(width: 40),
                Text("home", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(width: 30),
                Text("store", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 30),
                Text("discounts", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
          
          Row(
            children: [
              if (!isCompact) Icon(Icons.favorite_border, color: Colors.grey[600], size: 22),
              if (!isCompact) SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F1ED),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.black87), 
                    SizedBox(width: 6), 
                    Text("\$0.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                  ]
                ),
              ),
              SizedBox(width: 16),
              CircleAvatar(
                radius: 14, 
                backgroundColor: Colors.grey[300], 
                child: Icon(Icons.person, size: 18, color: Colors.grey[700])
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductDetails({required bool isDesktop}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 36 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("man • sweaters • GAP", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          SizedBox(height: 24),
          
          // Layout switch for Product info + image
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildProductImagePanel()),
                SizedBox(width: 32),
                Expanded(flex: 6, child: _buildProductInfoAndControls()),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImagePanel(height: 350),
                SizedBox(height: 24),
                _buildProductInfoAndControls(),
              ],
            ),
          
          SizedBox(height: 60),
          Text("Complete the Look", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          _buildCompleteLookSection(),
        ],
      ),
    );
  }

  Widget _buildProductImagePanel({double height = 450}) {
    return GestureDetector(
      onTap: () => _pickImage(false),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF3F1ED), // beige-ish
          borderRadius: BorderRadius.circular(24),
        ),
        child: _clothImage != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: kIsWeb ? Image.network(_clothImage!.path, fit: BoxFit.cover) : Image.file(File(_clothImage!.path), fit: BoxFit.cover)
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.grey[400], size: 48),
                  SizedBox(height: 16),
                  Text("Tap to upload cloth", style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }

  Widget _buildProductInfoAndControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GAP", style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        SizedBox(height: 8),
        Text("Classic Crewneck Sweater", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Row(
          children: [
            Row(children: List.generate(4, (i) => Icon(Icons.star, size: 16, color: Colors.grey[400]))),
            Icon(Icons.star_half, size: 16, color: Colors.grey[400]),
            SizedBox(width: 8),
            Text("158 reviews", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: 24),
        Text("\$49.95", style: TextStyle(color: Colors.grey[400], decoration: TextDecoration.lineThrough, fontSize: 16)),
        Text("\$39.00", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        Text("20% off: limited time", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        
        SizedBox(height: 32),
        Text("Category", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _categoryPill("Upper Body", 'upper_body'),
            _categoryPill("Lower Body", 'lower_body'),
            _categoryPill("Dress", 'dresses'),
          ],
        ),

        SizedBox(height: 32),
        Text("Color • Charcoal Grey", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _colorCircle(Colors.red[800]!),
            _colorCircle(Colors.green[800]!),
            _colorCircle(Colors.brown[800]!),
            _colorCircle(Colors.blueGrey[800]!),
            _colorCircle(Colors.grey[800]!, selected: true),
            _colorCircle(Colors.blue[800]!),
          ],
        ),
        SizedBox(height: 32),
        Text("Size • XL", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _sizeBox("XS"), _sizeBox("S"), _sizeBox("M"), _sizeBox("L"), _sizeBox("XL", selected: true), _sizeBox("XXL"),
          ],
        ),
        SizedBox(height: 40),
        
        // Action Buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  side: BorderSide(color: Colors.black, width: 1.5),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _generate,
                icon: _isLoading ? SpinKitThreeBounce(color: Colors.black, size: 16) : Icon(Icons.checkroom),
                label: Text("Try On", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF3F1ED),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                icon: Icon(Icons.shopping_cart_outlined),
                label: Text("Add to cart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(color: Color(0xFFF3F1ED), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.favorite_border, size: 24),
            )
          ],
        ),
      ],
    );
  }

  Widget _categoryPill(String title, String value) {
    bool isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Color(0xFFF3F1ED),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(Color c, {bool selected = false}) {
    return Container(
      width: selected ? 32 : 28, 
      height: selected ? 32 : 28,
      decoration: BoxDecoration(
        color: c, 
        shape: BoxShape.circle,
        border: selected ? Border.all(color: Colors.black87, width: 3) : Border.all(color: Colors.transparent),
      ),
    );
  }
  
  Widget _sizeBox(String s, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Color(0xFFF3F1ED),
        border: selected ? Border.all(color: Colors.black, width: 1.5) : null,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Text(s, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
    );
  }

  Widget _buildCompleteLookSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
           _dummyProductWidget("Relaxed Taper Jeans GapFlex", "\$25.00"),
           SizedBox(width: 16),
           _dummyProductWidget("Converse Chuck 70 Classic High", "\$69.00"),
           SizedBox(width: 16),
           _dummyProductWidget("Ripstop Overshirt", "\$123.99"),
        ]
      ),
    );
  }

  Widget _dummyProductWidget(String title, String price) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
         border: Border.all(color: Colors.grey[200]!),
         borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 160, decoration: BoxDecoration(color: Color(0xFFF3F1ED), borderRadius: BorderRadius.circular(12))),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 8),
          Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  icon: Icon(Icons.checkroom, size: 16),
                  label: Text("Try On", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              SizedBox(width: 8),
              Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.shopping_cart_outlined, size: 18)),
              SizedBox(width: 8),
              Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.favorite_border, size: 18)),
            ],
          )
        ]
      ),
    );
  }

  Widget _buildTryOnResult({required bool isMobile}) {
    return Container(
      height: isMobile ? 450 : double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFDFDDD8), // Match the result background color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if(!isMobile) BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ]
      ),
      child: Stack(
        children: [
          // Main Try-On View
          GestureDetector(
            onTap: () => _pickImage(true),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
              clipBehavior: Clip.hardEdge,
              child: _resultImage != null
                  ? Image.memory(_resultImage!, fit: BoxFit.cover)
                  : _personImage != null
                      ? kIsWeb ? Image.network(_personImage!.path, fit: BoxFit.cover) : Image.file(File(_personImage!.path), fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_1, size: 64, color: Colors.grey[600]),
                              SizedBox(height: 16),
                              Text("Tap here to upload model/your photo", style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
            ),
          ),
          
          // Floating Elements matching the UI
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.6),
              radius: 18,
              child: Icon(Icons.checkroom, color: Colors.black, size: 20),
            ),
          ),
          
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: Colors.black87, size: 20),
                  SizedBox(width: 12),
                  Icon(Icons.fullscreen, color: Colors.black87, size: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
