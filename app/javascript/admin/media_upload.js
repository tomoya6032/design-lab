// メディアアップロード用JavaScript
document.addEventListener('DOMContentLoaded', function() {
  const fileUploadArea = document.getElementById('file-upload-area');
  const fileInput = document.getElementById('file-input');
  const filePreview = document.getElementById('file-preview');
  const previewContent = document.getElementById('preview-content');
  const fileInfo = document.getElementById('file-info');
  const metadataSection = document.getElementById('metadata-section');
  const formActions = document.getElementById('form-actions');
  const altTextGroup = document.getElementById('alt-text-group');
  const titleInput = document.querySelector('input[name="medium[title]"]');
  
  let selectedFile = null;
  
  // ドラッグ&ドロップ機能
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    fileUploadArea.addEventListener(eventName, preventDefaults, false);
    document.body.addEventListener(eventName, preventDefaults, false);
  });
  
  ['dragenter', 'dragover'].forEach(eventName => {
    fileUploadArea.addEventListener(eventName, highlight, false);
  });
  
  ['dragleave', 'drop'].forEach(eventName => {
    fileUploadArea.addEventListener(eventName, unhighlight, false);
  });
  
  fileUploadArea.addEventListener('drop', handleDrop, false);
  fileUploadArea.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', handleFileSelect);
  
  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }
  
  function highlight(e) {
    fileUploadArea.classList.add('drag-over');
  }
  
  function unhighlight(e) {
    fileUploadArea.classList.remove('drag-over');
  }
  
  function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;
    handleFiles(files);
  }
  
  function handleFileSelect(e) {
    const files = e.target.files;
    handleFiles(files);
  }
  
  function handleFiles(files) {
    if (files.length > 0) {
      selectedFile = files[0];
      displayFilePreview(selectedFile);
      showMetadataSection();
    }
  }
  
  function displayFilePreview(file) {
    const fileType = file.type;
    const fileName = file.name;
    const fileSize = formatFileSize(file.size);
    
    // ファイル情報を表示
    document.getElementById('display-filename').textContent = fileName;
    document.getElementById('display-filetype').textContent = fileType;
    document.getElementById('display-filesize').textContent = fileSize;
    
    // タイトルを自動設定
    if (titleInput) {
      titleInput.value = fileName.replace(/\.[^/.]+$/, ''); // 拡張子を除いたファイル名
    }
    
    // プレビューを作成
    previewContent.innerHTML = '';
    
    if (fileType.startsWith('image/')) {
      const img = document.createElement('img');
      img.src = URL.createObjectURL(file);
      img.className = 'preview-image';
      img.onload = () => URL.revokeObjectURL(img.src);
      previewContent.appendChild(img);
      
      // 画像の場合はalt属性フィールドを表示
      altTextGroup.style.display = 'block';
    } else if (fileType.startsWith('video/')) {
      const video = document.createElement('video');
      video.src = URL.createObjectURL(file);
      video.className = 'preview-video';
      video.controls = true;
      video.onload = () => URL.revokeObjectURL(video.src);
      previewContent.appendChild(video);
    } else if (fileType.startsWith('audio/')) {
      const audio = document.createElement('audio');
      audio.src = URL.createObjectURL(file);
      audio.className = 'preview-audio';
      audio.controls = true;
      audio.onload = () => URL.revokeObjectURL(audio.src);
      previewContent.appendChild(audio);
    } else {
      // その他のファイル（PDF、ドキュメントなど）
      const fileIcon = document.createElement('div');
      fileIcon.className = 'file-icon';
      fileIcon.innerHTML = getFileIcon(fileType);
      previewContent.appendChild(fileIcon);
    }
    
    filePreview.style.display = 'block';
  }
  
  function showMetadataSection() {
    metadataSection.style.display = 'block';
    formActions.style.display = 'block';
  }
  
  function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
  
  function getFileIcon(fileType) {
    if (fileType.includes('pdf')) return '📄';
    if (fileType.includes('word') || fileType.includes('document')) return '📝';
    if (fileType.includes('excel') || fileType.includes('spreadsheet')) return '📊';
    if (fileType.startsWith('audio/')) return '🎵';
    if (fileType.startsWith('video/')) return '🎬';
    return '📎'; // デフォルトアイコン
  }
});