// Design Lab CMS Application JavaScript
// This file is compiled by Sprockets and served alongside the application

console.log("Design Lab CMS - Application loaded");

// DOM読み込み完了後にタブ機能を初期化
document.addEventListener('DOMContentLoaded', function() {
  console.log("DOM loaded, initializing tabs...");
  initializeTabs();
  initializeThemeCustomization();
  initializeArticleForms();
});

function initializeTabs() {
  const tabItems = document.querySelectorAll('.tab-item');
  const tabContents = document.querySelectorAll('.tab-content');

  console.log("Found tabs:", tabItems.length, "contents:", tabContents.length);

  if (tabItems.length === 0) return;

  // タブクリック時の処理
  tabItems.forEach(function(tabItem) {
    tabItem.addEventListener('click', function(e) {
      e.preventDefault();
      
      const targetTab = this.dataset.tab;
      console.log('Tab clicked:', targetTab);
      
      // 全てのタブを非アクティブに
      tabItems.forEach(function(item) {
        item.classList.remove('active');
      });
      
      // 全てのコンテンツを非表示に
      tabContents.forEach(function(content) {
        content.classList.remove('active');
      });
      
      // クリックされたタブをアクティブに
      this.classList.add('active');
      
      // 対応するコンテンツを表示
      const targetContent = document.querySelector('[data-content="' + targetTab + '"]');
      if (targetContent) {
        targetContent.classList.add('active');
        console.log('Content switched to:', targetTab);
      } else {
        console.log('Content not found for:', targetTab);
      }
    });
  });
}

function initializeThemeCustomization() {
  // カラーピッカーと入力フィールドの同期
  const colorInputs = document.querySelectorAll('.color-input');
  const colorTexts = document.querySelectorAll('.color-text');

  colorInputs.forEach(function(colorInput, index) {
    colorInput.addEventListener('change', function() {
      const correspondingText = colorTexts[index];
      if (correspondingText) {
        correspondingText.value = this.value;
        updatePreview();
      }
    });
  });

  colorTexts.forEach(function(colorText, index) {
    colorText.addEventListener('input', function() {
      const correspondingInput = colorInputs[index];
      if (correspondingInput && isValidColor(this.value)) {
        correspondingInput.value = this.value;
        updatePreview();
      }
    });
  });

  function isValidColor(color) {
    return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(color);
  }

  function updatePreview() {
    const previewHeader = document.querySelector('.preview-header');
    const previewCard = document.querySelector('.preview-card');
    const previewButton = document.querySelector('.preview-button');
    
    if (!previewHeader || !previewCard || !previewButton) return;

    const primaryColor = document.querySelector('input[name*="primary_color"]');
    const borderRadius = document.querySelector('input[name*="border_radius"]');
    const boxShadow = document.querySelector('select[name*="box_shadow"]');
    const headerHeight = document.querySelector('input[name*="header_height"]');

    if (primaryColor) {
      previewHeader.style.background = primaryColor.value;
      previewButton.style.background = primaryColor.value;
    }

    if (borderRadius) {
      previewCard.style.borderRadius = borderRadius.value + 'px';
      previewButton.style.borderRadius = borderRadius.value + 'px';
    }

    if (boxShadow) {
      previewCard.style.boxShadow = boxShadow.value;
    }

    if (headerHeight) {
      previewHeader.style.height = headerHeight.value + 'px';
    }
  }
}

function initializeArticleForms() {
  // タイトルからスラッグを自動生成
  const titleField = document.querySelector('input[name*="title"]');
  const slugField = document.querySelector('input[name*="slug"]');
  
  if (titleField && slugField) {
    titleField.addEventListener('input', function() {
      // スラッグフィールドが空の場合のみ自動生成
      if (!slugField.value.trim()) {
        const slug = generateSlug(this.value);
        slugField.value = slug;
      }
    });
    
    // スラッグフィールドの入力時にクリーンアップ
    slugField.addEventListener('input', function() {
      this.value = generateSlug(this.value);
    });
  }
  
  function generateSlug(text) {
    return text
      .toLowerCase()
      .replace(/[^\w\s-]/g, '') // 特殊文字を削除
      .replace(/[\s_-]+/g, '-') // スペース、アンダースコア、ハイフンをハイフンに変換
      .replace(/^-+|-+$/g, ''); // 先頭末尾のハイフンを削除
  }
}