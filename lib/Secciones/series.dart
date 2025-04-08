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
  List<MediaItem> _filteredSeriesList = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFilter = 'Ninguno';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadSeries();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_filterSeries);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterSeries() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredSeriesList = _seriesList;
        _isSearching = false;
      } else {
        _filteredSeriesList = _seriesList
            .where((series) => 
                (series.title?.toLowerCase() ?? '').contains(query))
            .toList();
        _isSearching = true;
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredSeriesList = _seriesList;
      _isSearching = false;
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Fecha de Lanzamiento':
          _filteredSeriesList.sort((a, b) {
            final dateA = a.releaseDate ?? '';
            final dateB = b.releaseDate ?? '';
            return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          });
          break;
        case 'Rating':
          _filteredSeriesList.sort((a, b) {
            final ratingA = a.voteAverage ?? 0.0;
            final ratingB = b.voteAverage ?? 0.0;
            return _isAscending ? ratingA.compareTo(ratingB) : ratingB.compareTo(ratingA);
          });
          break;
        case 'Orden Alfabético':
          _filteredSeriesList.sort((a, b) {
            final titleA = a.title ?? '';
            final titleB = b.title ?? '';
            return _isAscending ? titleA.compareTo(titleB) : titleB.compareTo(titleA);
          });
          break;
        default:
          _filteredSeriesList = List.from(_seriesList);
          break;
      }
    });
  }

  void _onScroll() {
    if (!_isSearching && 
        _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
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
          _filteredSeriesList = series;
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
    if (_isLoadingMore || _isSearching) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final moreSeries = await TMDBService.getPopularContent(isMovie: false, page: _currentPage);
      if (mounted) {
        setState(() {
          _seriesList.addAll(moreSeries);
          _filteredSeriesList = _searchController.text.isEmpty 
              ? _seriesList 
              : _filteredSeriesList;
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar series...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? Colors.white60 : Colors.black45,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.filter_list,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          tooltip: 'Filtrar por',
                          onSelected: (String value) {
                            setState(() {
                              _isAscending = !_isAscending;
                            });
                            _applyFilter(value);
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'Fecha de Lanzamiento',
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 20),
                                  SizedBox(width: 8),
                                  Text('Fecha de Lanzamiento'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Rating',
                              child: Row(
                                children: [
                                  Icon(Icons.star, size: 20),
                                  SizedBox(width: 8),
                                  Text('Rating'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Orden Alfabético',
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha, size: 20),
                                  SizedBox(width: 8),
                                  Text('Orden Alfabético'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          onPressed: () {
                            setState(() {
                              _isAscending = !_isAscending;
                            });
                            _applyFilter(_selectedFilter);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                      : _filteredSeriesList.isEmpty && _searchController.text.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.tv,
                                    color: isDark ? Colors.white54 : Colors.black38,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No se encontraron series con "${_searchController.text}"',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
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
                              itemCount: _filteredSeriesList.length + 
                                  (!_isSearching && _isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (!_isSearching && index == _filteredSeriesList.length) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                return _buildSeriesCard(_filteredSeriesList[index]);
                              },
                            ),
            ),
          ],
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
