// メディア削除確認モーダル
document.addEventListener('DOMContentLoaded', function() {
  // 削除ボタンのクリック処理
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('delete-media-btn')) {
      e.preventDefault();
      
      const mediaId = e.target.dataset.mediaId;
      const mediaTitle = e.target.dataset.mediaTitle;
      const deleteUrl = e.target.href;
      
      showDeleteConfirmModal(mediaId, mediaTitle, deleteUrl);
    }
  });
  
  function showDeleteConfirmModal(mediaId, mediaTitle, deleteUrl) {
    // モーダルHTMLを動的生成
    const modalHtml = `
      <div id="delete-confirm-modal" class="modal-overlay">
        <div class="modal-content">
          <div class="modal-header">
            <h3>メディアの削除確認</h3>
            <button class="modal-close" onclick="closeDeleteModal()">&times;</button>
          </div>
          <div class="modal-body">
            <div class="warning-icon">⚠️</div>
            <p>以下のメディアファイルを削除しますか？</p>
            <div class="media-info">
              <strong>${mediaTitle || '無題'}</strong>
            </div>
            <p class="warning-text">この操作は取り消すことができません。</p>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeDeleteModal()">キャンセル</button>
            <button class="btn btn-danger" onclick="confirmDelete('${deleteUrl}')">削除する</button>
          </div>
        </div>
      </div>
    `;
    
    // モーダルをDOMに追加
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    
    // モーダル表示
    const modal = document.getElementById('delete-confirm-modal');
    modal.style.display = 'flex';
    
    // ESCキーで閉じる
    document.addEventListener('keydown', handleEscKey);
  }
  
  // モーダルを閉じる
  window.closeDeleteModal = function() {
    const modal = document.getElementById('delete-confirm-modal');
    if (modal) {
      modal.remove();
      document.removeEventListener('keydown', handleEscKey);
    }
  };
  
  // 削除実行
  window.confirmDelete = function(deleteUrl) {
    // CSRFトークンを取得
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    
    // DELETE リクエストを送信
    fetch(deleteUrl, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      }
    })
    .then(response => {
      if (response.ok || response.status === 302) {
        // 成功時はページリロード
        window.location.reload();
      } else {
        alert('削除に失敗しました。');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('削除中にエラーが発生しました。');
    })
    .finally(() => {
      closeDeleteModal();
    });
  };
  
  // ESCキーハンドラー
  function handleEscKey(e) {
    if (e.key === 'Escape') {
      closeDeleteModal();
    }
  }
  
  // モーダル外クリックで閉じる
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal-overlay')) {
      closeDeleteModal();
    }
  });
});