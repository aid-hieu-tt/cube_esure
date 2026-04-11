# 🚀 Production Checklist — Cube.js API


## Bắt buộc

- [ ] **1. DB production** — đổi 5 biến `CUBEJS_DB_*` trỏ tới DB production
- [ ] **2. Tắt dev mode** — `CUBEJS_DEV_MODE=false` (bật auth + tắt Playground)
- [ ] **3. CORS** — thêm domain Dashboard vào `cube.js`

```javascript
// cube.js
module.exports = {
  http: {
    cors: {
      origin: ['https://dashboard.your-domain.com'],
      credentials: true,
    },
  },
};
```

## Sau khi deploy

- [ ] **4. Tạo JWT token** gửi cho team Dashboard

```bash
node -e "const jwt=require('jsonwebtoken'); console.log(jwt.sign({}, process.env.CUBEJS_API_SECRET, {expiresIn:'365d'}))"
```

- [ ] **5. Test** — `curl https://your-api/readyz` → OK

---

> Các biến khác (`CUBEJS_API_SECRET`, `CUBEJS_SCHEMA_PATH`...) giữ nguyên giá trị hiện tại là được.
> Phần cache/pre-aggregation, Nginx, SSL... là tùy chọn, thêm sau khi cần.
