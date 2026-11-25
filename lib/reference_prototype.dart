import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const GemStoreApp());
}

class GemStoreApp extends StatelessWidget {
  const GemStoreApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GemStore',
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: false,
    ),
    home: const StoreScreen(),
  );
}

// Reference screen coordinates are measured directly from the supplied image.
// All hotspots scale with the image, preserving exact visual proportions.
class ReferenceCanvas extends StatelessWidget {
  const ReferenceCanvas({
    super.key,
    required this.asset,
    required this.referenceWidth,
    required this.referenceHeight,
    required this.hotspots,
    this.overlays = const [],
  });
  final String asset;
  final double referenceWidth, referenceHeight;
  final List<ReferenceHotspot> hotspots;
  final List<Widget Function(double)> overlays;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = constraints.maxWidth / referenceWidth;
      return SingleChildScrollView(
        child: SizedBox(
          width: constraints.maxWidth,
          height: referenceHeight * scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  asset,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
              ...hotspots.map(
                (h) => Positioned(
                  left: h.x * scale,
                  top: h.y * scale,
                  width: h.width * scale,
                  height: h.height * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: h.onTap,
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              ),
              ...overlays.map((builder) => builder(scale)),
            ],
          ),
        ),
      );
    },
  );
}

class ReferenceHotspot {
  const ReferenceHotspot(this.x, this.y, this.width, this.height, this.onTap);
  final double x, y, width, height;
  final VoidCallback onTap;
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    void openProduct() => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProductScreen()));
    void message(String value) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), duration: const Duration(seconds: 2)),
    );
    return Scaffold(
      body: ReferenceCanvas(
        asset: 'assets/images/home.png',
        referenceWidth: 298,
        referenceHeight: 1364,
        hotspots: [
          ReferenceHotspot(22, 46, 35, 37, () => message('Meniu GemStore')),
          ReferenceHotspot(245, 43, 35, 42, () => message('Notificări')),
          ReferenceHotspot(
            18,
            96,
            264,
            60,
            () => message('Categorii: Women · Men · Accessories · Beauty'),
          ),
          ReferenceHotspot(24, 170, 251, 136, openProduct),
          ReferenceHotspot(24, 367, 103, 190, openProduct),
          ReferenceHotspot(140, 367, 106, 190, openProduct),
          ReferenceHotspot(258, 367, 40, 190, openProduct),
          ReferenceHotspot(21, 567, 259, 137, openProduct),
          ReferenceHotspot(22, 760, 260, 62, openProduct),
          ReferenceHotspot(20, 890, 263, 120, openProduct),
          ReferenceHotspot(20, 1015, 263, 172, openProduct),
          ReferenceHotspot(20, 1190, 263, 170, openProduct),
        ],
      ),
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedSize = 2;
  int selectedColor = 0;
  bool favorite = false;
  int cartCount = 0;

  void showInfo(String title, String body) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder:
        (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(body),
              const SizedBox(height: 20),
            ],
          ),
        ),
  );

  @override
  Widget build(BuildContext context) {
    Widget circle(
      double scale,
      double x,
      double y,
      Color color,
      bool selected,
      VoidCallback tap,
    ) => Positioned(
      left: x * scale,
      top: y * scale,
      width: 25 * scale,
      height: 25 * scale,
      child: GestureDetector(
        onTap: tap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3 * scale),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 4 * scale,
                      ),
                    ]
                    : null,
          ),
        ),
      ),
    );
    return Scaffold(
      body: ReferenceCanvas(
        asset: 'assets/images/detail.png',
        referenceWidth: 299,
        referenceHeight: 1447,
        hotspots: [
          ReferenceHotspot(20, 42, 40, 43, () => Navigator.of(context).pop()),
          ReferenceHotspot(
            237,
            43,
            45,
            42,
            () => setState(() => favorite = !favorite),
          ),
          ReferenceHotspot(
            21,
            450,
            28,
            35,
            () => setState(() => selectedColor = 0),
          ),
          ReferenceHotspot(
            58,
            450,
            27,
            35,
            () => setState(() => selectedColor = 1),
          ),
          ReferenceHotspot(
            84,
            450,
            28,
            35,
            () => setState(() => selectedColor = 2),
          ),
          ReferenceHotspot(
            181,
            450,
            28,
            35,
            () => setState(() => selectedSize = 0),
          ),
          ReferenceHotspot(
            214,
            450,
            28,
            35,
            () => setState(() => selectedSize = 1),
          ),
          ReferenceHotspot(
            244,
            450,
            30,
            35,
            () => setState(() => selectedSize = 2),
          ),
          ReferenceHotspot(
            20,
            515,
            259,
            135,
            () => showInfo(
              'Description',
              'Sportwear is no longer under culture, it is no longer indie or cobbled together as it once was. Sport is fashion today.',
            ),
          ),
          ReferenceHotspot(
            20,
            657,
            259,
            460,
            () => showInfo(
              'Reviews',
              '4.9 out of 5 · 83 ratings. Customer reviews from Jennifer Rose and Kelly Rihanna.',
            ),
          ),
          ReferenceHotspot(
            20,
            1120,
            259,
            258,
            () => showInfo(
              'Similar Product',
              'Explore more products from the GemStore collection.',
            ),
          ),
          ReferenceHotspot(0, 1385, 299, 62, () {
            setState(() => cartCount++);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added to cart · ${['S', 'M', 'L'][selectedSize]} · $cartCount item(s)',
                ),
              ),
            );
          }),
        ],
        overlays: [
          (scale) =>
              favorite
                  ? Positioned(
                    left: 252 * scale,
                    top: 54 * scale,
                    child: Icon(
                      Icons.favorite,
                      color: const Color(0xfff36b79),
                      size: 20 * scale,
                    ),
                  )
                  : const SizedBox.shrink(),
          (scale) =>
              selectedSize != 2
                  ? Positioned(
                    left: (193 + selectedSize * 32).toDouble() * scale,
                    top: 466 * scale,
                    child: Container(
                      width: 26 * scale,
                      height: 26 * scale,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xff555555),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        ['S', 'M', 'L'][selectedSize],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * scale,
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
          (scale) =>
              selectedColor != 0
                  ? circle(
                    scale,
                    selectedColor == 1 ? 58 : 85,
                    463,
                    [
                      const Color(0xffe8c1ac),
                      Colors.black,
                      const Color(0xfff26b71),
                    ][selectedColor],
                    true,
                    () => setState(() => selectedColor = selectedColor),
                  )
                  : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
