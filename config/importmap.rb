# Pin npm packages by running ./bin/importmap

pin "application"
# 一時的にadmin関連JSを無効化（Cropperエラー回避のため）
# pin "admin/media_upload", to: "admin/media_upload.js"
# pin "admin/media_delete", to: "admin/media_delete.js"
# pin "admin/media_edit", to: "admin/media_edit.js"
# pin "admin/media_selector", to: "admin/media_selector.js"
# 一時的にCropper関連をコメントアウト（404エラー解決のため）
# pin "cropperjs" # @2.1.0
# pin "@cropper/element", to: "@cropper--element.js" # @2.1.0
# pin "@cropper/element-canvas", to: "@cropper--element-canvas.js" # @2.1.0
# pin "@cropper/element-crosshair", to: "@cropper--element-crosshair.js" # @2.1.0
# pin "@cropper/element-grid", to: "@cropper--element-grid.js" # @2.1.0
# pin "@cropper/element-handle", to: "@cropper--element-handle.js" # @2.1.0
# pin "@cropper/element-image", to: "@cropper--element-image.js" # @2.1.0
# pin "@cropper/element-selection", to: "@cropper--element-selection.js" # @2.1.0
# pin "@cropper/element-shade", to: "@cropper--element-shade.js" # @2.1.0
# pin "@cropper/element-viewer", to: "@cropper--element-viewer.js" # @2.1.0
# pin "@cropper/elements", to: "@cropper--elements.js" # @2.1.0
# pin "@cropper/utils", to: "@cropper--utils.js" # @2.1.0
