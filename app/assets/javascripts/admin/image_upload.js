// Image Upload Preview functionality
document.addEventListener('DOMContentLoaded', function() {
  const imageInput = document.querySelector('.image-upload-input');
  const previewContainer = document.querySelector('.image-preview-container');
  const previewPlaceholder = document.querySelector('.preview-placeholder');
  const currentImage = document.querySelector('.current-image');
  
  if (!imageInput || !previewContainer) return;
  
  imageInput.addEventListener('change', function(e) {
    const file = e.target.files[0];
    
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      
      reader.onload = function(e) {
        const previewImg = previewPlaceholder.querySelector('.preview-image');
        previewImg.src = e.target.result;
        
        // 現在の画像を非表示にし、プレビューを表示
        if (currentImage) {
          currentImage.style.display = 'none';
        }
        previewPlaceholder.style.display = 'block';
      };
      
      reader.readAsDataURL(file);
    } else if (file) {
      alert('画像ファイルを選択してください（JPG、PNG、GIF）');
      imageInput.value = '';
    }
  });
  
  // ドラッグ&ドロップ機能
  const uploadLabel = document.querySelector('.image-upload-label');
  
  if (uploadLabel) {
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      uploadLabel.addEventListener(eventName, preventDefaults, false);
    });
    
    ['dragenter', 'dragover'].forEach(eventName => {
      uploadLabel.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
      uploadLabel.addEventListener(eventName, unhighlight, false);
    });
    
    uploadLabel.addEventListener('drop', handleDrop, false);
  }
  
  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }
  
  function highlight(e) {
    uploadLabel.classList.add('drag-over');
  }
  
  function unhighlight(e) {
    uploadLabel.classList.remove('drag-over');
  }
  
  function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;
    
    if (files.length > 0) {
      imageInput.files = files;
      // changeイベントを手動でトリガー
      const event = new Event('change', { bubbles: true });
      imageInput.dispatchEvent(event);
    }
  }
});