
//画像アップロード時のプレビュー表示
$(document).ready(function () {
  var view_box = $('.view_box');

  $(".file").on('change', function(){
     var fileprop = $(this).prop('files')[0],
         find_img = $(this).next('img'),
         fileRdr = new FileReader();

     if(find_img.length){
        find_img.nextAll().remove();
        find_img.remove();
     }

    var img = '<img width="200" alt="" class="img_view"><a href="#" class="img_del" color="#006B8C">削除</a>';
    view_box.append(img);

    fileRdr.onload = function() {
      view_box.find('img').attr('src', fileRdr.result);
      img_del(view_box);
    }
    fileRdr.readAsDataURL(fileprop);
  });

  function img_del(target)
  {
     target.find("a.img_del").on('click',function(){

      if(window.confirm('サーバーから画像を削除します。\nよろしいですか？'))
      {
         $(this).parent().find('input[type=file]').val('');
         $(this).parent().find('.img_view, br').remove();
         $(this).remove();
      }

      return false;
    });
  }
});


$(function(){
    $(".open").click(function(){
        $("#slideBox").slideToggle("slow");
    });
});






//■page topボタン

$(function(){
var topBtn=$('#pageTop');
topBtn.hide();



//◇ボタンの表示設定
$(window).scroll(function(){
  if($(this).scrollTop()>80){

    //---- 画面を80pxスクロールしたら、ボタンを表示する
    topBtn.fadeIn();

  }else{

    //---- 画面が80pxより上なら、ボタンを表示しない
    topBtn.fadeOut();

  }
});



// ◇ボタンをクリックしたら、スクロールして上に戻る
topBtn.click(function(){
  $('body,html').animate({
  scrollTop: 0},500);
  return false;

});


});