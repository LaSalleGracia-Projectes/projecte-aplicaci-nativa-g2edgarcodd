import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamhub/Services/tmdb_service.dart';
import 'package:streamhub/Models/media_item.dart';
import 'package:streamhub/theme_provider.dart';

class SeriesView extends StatefulWidget {
  const SeriesView({super.key});

  @override
  _SeriesViewState createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView> {
  List<MediaItem> _seriesList = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadSeries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreSeries();
    }
  }

  Future<void> _loadSeries() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final series = await TMDBService.getPopularContent(isMovie: false);
      if (mounted) {
        setState(() {
          _seriesList = series;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      print("Error cargando series: $e");
    }
  }

  Future<void> _loadMoreSeries() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final moreSeries = await TMDBService.getPopularContent(isMovie: false, page: _currentPage);
      if (mounted) {
        setState(() {
          _seriesList.addAll(moreSeries);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
      print("Error cargando más series: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Series', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24)),
        backgroundColor: isDark ? Color(0xFF060D17) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF060D17) : Colors.white,
          image: DecorationImage(
            image: AssetImage('images/fondo2.png'),
            opacity: isDark ? 0.10 : 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar las series',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSeries,
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: _seriesList.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _seriesList.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return _buildSeriesCard(_seriesList[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildSeriesCard(MediaItem series) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    String imageUrl = TMDBService.getImageUrl(series.posterPath ?? '');
    String rating = (series.voteAverage ?? 0.0).toStringAsFixed(1);
    String year = (series.releaseDate != null && series.releaseDate!.isNotEmpty && series.releaseDate!.length >= 4)
        ? series.releaseDate!.substring(0, 4)
        : "Sin fecha";
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has seleccionado: ${series.title ?? "Sin título"}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              (series.posterPath == null || series.posterPath!.isEmpty)
                  ? Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(
                          Icons.tv,
                          size: 24,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: Icon(Icons.error, color: Colors.white, size: 20),
                          ),
                        );
                      },
                    ),
              
              // Gradiente para el texto
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        series.title ?? 'Sin título',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            year,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 10),
                                SizedBox(width: 1),
                                Text(
                                  rating,
                                  style: TextStyle(color: Colors.white, fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
