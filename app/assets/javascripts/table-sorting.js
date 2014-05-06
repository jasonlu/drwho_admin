$(document).ready(function(){

  $('tr.sortable>th').click(function(){
    var sorting = $(this).data('sorting');
    var jump = $(this).data('jump');
    if (typeof sorting == 'undefined') {
      return false;
    }
    
    if($(this).hasClass('asc')) {
      dir = 'desc';
      $(this).removeClass('asc').addClass('desc');
    } else if ($(this).hasClass('desc')) {
      dir = 'asc';
      $(this).removeClass('desc').addClass('asc');
    } else {
      dir = 'desc';
      $(this).removeClass('asc').addClass('desc');
    }
    
    var base_url = window.location.href.substring(0, window.location.toString().indexOf('?'));
    var query_string = "";
    var queries = {};
    if(window.location.toString().indexOf('?') > 0) {
      query_string = window.location.href.substring(window.location.toString().indexOf('?') + 1);
      //console.log(query_string);
      // Deserialize query string to object.
      queries = $.deparam(query_string);
    }
    // Change value, serialize  to query string.
    queries.sort = sorting;
    queries.dir = dir;

    if (typeof jump == 'undefined') {
      full_url = base_url + '?' + $.param(queries);
    } else {
      full_url = base_url + '?' + $.param(queries) + '#' + jump;
    }
    window.location.href = full_url;
  });

  var default_sorting_and_dir = $('meta[name=sorting]').attr('content');
  if(typeof default_sorting_and_dir != 'undefined') {
    var separate_at = default_sorting_and_dir.lastIndexOf('_');
    default_sorting = default_sorting_and_dir.substring(0, separate_at);
    default_dir = default_sorting_and_dir.substring(separate_at + 1);
    down_arrow_class = 'icon-chevron-down';
    up_arrow_class = 'icon-chevron-up';
    both_arrow_class = '';

    if(default_dir == 'asc') {
      arrow_class = up_arrow_class;
    } else {
      arrow_class = down_arrow_class;
    }
    var arrow = "<i class='" + arrow_class + " pull-right'>&nbsp;</i>";

    $('th.' + default_sorting).addClass(default_dir).addClass('sorting').append(arrow);
  }
});