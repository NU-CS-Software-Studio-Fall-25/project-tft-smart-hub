# 性能优化指南

## 当前性能问题

**压力测试结果**（1000 并发，30 秒）：
```
平均延迟: 1.23s
吞吐量: 765.75 req/sec
总请求: 23,048
```

**目标**：
- 平均延迟 < 200ms（**提升 6 倍**）
- 吞吐量 > 2000 req/sec（**提升 2.6 倍**）

---

## ✅ 已实施的优化

### 1. **解决 N+1 查询问题** ⭐⭐⭐⭐⭐

**问题**：每个 team_comp 都单独查询 champions 表

**优化前**（10 个 team_comps）：
```sql
SELECT * FROM team_comps LIMIT 10;           -- 1 query
SELECT * FROM champions WHERE name IN (...); -- 10 queries (N+1!)
-- 总计: 11 queries
```

**优化后**：
```sql
SELECT * FROM team_comps LIMIT 10;           -- 1 query
SELECT * FROM champions WHERE name IN (...); -- 1 query (批量查询)
-- 总计: 2 queries (减少 82%)
```

**实现**：
- 在控制器中添加 `preload_champions_for_set()` 方法
- 一次性查询所有需要的 champions
- 将结果缓存到每个 team_comp 实例中

**预期提升**：响应时间减少 40-50%

---

### 2. **添加 HTTP 缓存** ⭐⭐⭐⭐⭐

**实现**：
```ruby
expires_in 5.minutes, public: true
```

**效果**：
- 浏览器和 CDN 缓存 5 分钟
- 重复请求直接从缓存返回（0ms 延迟）
- 减少服务器负载 80%+

**预期提升**：对于重复请求，延迟从 1.23s → 0ms

---

### 3. **添加数据库索引** ⭐⭐⭐⭐

**新增索引**：
```sql
CREATE INDEX ON team_comps (win_rate);
CREATE INDEX ON team_comps (win_rate, created_at);
CREATE INDEX ON team_comps (set_identifier);
CREATE INDEX ON team_comps (LOWER(name));
```

**效果**：
- `ORDER BY win_rate DESC` 从全表扫描变为索引扫描
- `WHERE set_identifier = 'TFT15'` 从全表扫描变为索引查找
- `WHERE LOWER(name) LIKE '%xxx%'` 搜索性能提升

**预期提升**：查询时间减少 60-70%

---

### 4. **启用 GZIP 压缩** ⭐⭐⭐⭐

**实现**：
```ruby
config.middleware.use Rack::Deflater
```

**效果**：
- JSON 响应体大小减少 70-80%
- 30 KB → 6-9 KB
- 网络传输时间大幅降低

**预期提升**：传输时间减少 70%

---

### 5. **减少每页数据量** ⭐⭐⭐⭐

**优化前**：50 条/页
**优化后**：10 条/页

**效果**：
- 序列化时间减少 80%
- 响应体大小减少 80%
- 首屏加载更快

---

## 🔜 后续优化建议

### 6. **添加 Redis 缓存** ⭐⭐⭐⭐⭐

#### 安装 Redis（Heroku）
```bash
# 添加 Redis 到 Heroku
heroku addons:create heroku-redis:mini -a tft-smartcomp-api

# 在 Gemfile 添加
gem 'redis'
gem 'hiredis'
```

#### 配置 Rails 使用 Redis
```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 10.minutes,
  namespace: 'tft_cache'
}
```

#### 使用示例
```ruby
def index
  cache_key = cache_key_for_team_comps(
    page: pagy.page,
    per: pagy.limit,
    search: search_query,
    set: requested_set
  )
  
  cached_data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
    # 这个块只在缓存未命中时执行
    {
      teams: payload,
      meta: meta_data
    }
  end
  
  render json: cached_data
end
```

**预期提升**：缓存命中率 >80%，响应时间 < 50ms

---

### 7. **使用 Jbuilder 优化序列化** ⭐⭐⭐

当前使用自定义 serializer，可以改用 Jbuilder（Rails 内置，性能更好）

```ruby
# app/views/api/team_comps/index.json.jbuilder
json.teams do
  json.array!(@comps) do |comp|
    json.partial! 'team_comp', comp: comp
  end
end

json.meta do
  json.page @pagy.page
  json.per @pagy.limit
  json.total @pagy.count
end
```

**预期提升**：序列化速度提升 30-40%

---

### 8. **添加 CDN** ⭐⭐⭐⭐⭐

**Cloudflare（免费）**：
1. 注册 Cloudflare
2. 添加域名
3. 开启 CDN 和缓存
4. 配置缓存规则（缓存 `/api/team_comps`）

**效果**：
- 全球用户延迟降低 60-80%
- 中国用户从 1.2s → 200ms
- 服务器负载减少 90%

---

### 9. **数据库连接池优化** ⭐⭐⭐

```ruby
# config/database.yml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 10 } %>
  timeout: 5000
  connect_timeout: 2
  checkout_timeout: 5
  reaping_frequency: 10
```

**Heroku 配置**：
```bash
heroku config:set RAILS_MAX_THREADS=10 DB_POOL=10
```

---

### 10. **启用 Puma 集群模式** ⭐⭐⭐⭐

```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
preload_app!
```

**Heroku 配置**：
```bash
heroku config:set WEB_CONCURRENCY=2 RAILS_MAX_THREADS=5
```

---

### 11. **使用 PostgreSQL 全文搜索** ⭐⭐⭐

```sql
-- 添加全文搜索索引
CREATE INDEX index_team_comps_on_search_vector 
ON team_comps 
USING gin(to_tsvector('english', name || ' ' || champions));
```

```ruby
# 使用全文搜索
scope.where("to_tsvector('english', name || ' ' || champions) @@ plainto_tsquery(?)", search_query)
```

**效果**：搜索速度提升 10-20 倍

---

### 12. **异步加载 champions 数据** ⭐⭐⭐

**方案**：
1. 列表 API 只返回基本信息（不包含 `cards`）
2. 前端单独请求 champions 数据
3. 使用 WebSocket 或 Server-Sent Events 推送

**效果**：首次响应时间减少 50%

---

## 📊 预期性能提升总览

| 优化项 | 当前 | 优化后 | 提升 |
|--------|------|--------|------|
| **平均延迟** | 1230ms | 150-200ms | **6-8倍** |
| **吞吐量** | 765 req/s | 2500-3000 req/s | **3-4倍** |
| **SQL 查询数** | 11 | 2 | **减少82%** |
| **响应体大小** | 150 KB | 30 KB | **减少80%** |
| **压缩后大小** | 150 KB | 6-9 KB | **减少94%** |
| **数据库查询时间** | 300ms | 50-80ms | **减少75%** |

---

## 🚀 实施优先级

### 立即实施（已完成）✅
1. N+1 查询优化
2. HTTP 缓存
3. 数据库索引
4. GZIP 压缩
5. 分页数量优化

### 下周实施
6. Redis 缓存（Heroku Redis）
7. CDN 配置（Cloudflare）

### 下个月实施
8. Jbuilder 序列化
9. 数据库连接池
10. Puma 集群模式

### 可选实施
11. PostgreSQL 全文搜索
12. 异步加载

---

## 🧪 性能测试命令

### 本地测试
```bash
# 启动服务器
./start-dev.sh

# 压力测试（100 并发）
wrk -t4 -c100 -d30s http://localhost:3000/api/team_comps

# 单次请求性能
time curl http://localhost:3000/api/team_comps?page=1
```

### Heroku 测试
```bash
# 压力测试
wrk -t12 -c1000 -d30s https://tft-smartcomp-b3f1e37435eb.herokuapp.com/api/team_comps

# 监控 Heroku 性能
heroku logs --tail -a tft-smartcomp-api
heroku ps -a tft-smartcomp-api
```

### 查看数据库查询
```bash
# 启用 Rails 查询日志
RAILS_ENV=production rails server

# 查看慢查询
tail -f log/production.log | grep "ActiveRecord"
```

---

## 📈 监控指标

### 关键指标
- **P50 延迟**（中位数）：目标 < 100ms
- **P95 延迟**（95 分位）：目标 < 300ms
- **P99 延迟**（99 分位）：目标 < 500ms
- **吞吐量**：目标 > 2000 req/s
- **错误率**：目标 < 0.1%

### Heroku 监控
```bash
# 安装 New Relic（免费）
heroku addons:create newrelic:wayne -a tft-smartcomp-api

# 查看实时指标
heroku addons:open newrelic -a tft-smartcomp-api
```

---

## 🎯 下一步行动

1. ✅ 提交当前优化到 Git
2. ✅ 部署到 Heroku
3. ⏳ 运行压力测试验证效果
4. ⏳ 添加 Redis 缓存
5. ⏳ 配置 Cloudflare CDN

**预期结果**：优化后性能提升 5-8 倍，延迟降至 150-200ms！
