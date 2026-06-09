-- ============================================
-- 记忆漂流瓶 — Supabase 云同步数据库初始化
-- ============================================
-- 在 Supabase 项目 → SQL Editor 中运行此脚本
--
-- ⚠️ 运行前请确保已在 Authentication → Providers 中启用 Email 登录
--   （可关闭 "Confirm email" 以避免邮箱验证步骤）

-- 1. 重建记忆表（如果之前创建过旧版本，先删除）
DROP TABLE IF EXISTS attachments CASCADE;
DROP TABLE IF EXISTS memories CASCADE;

CREATE TABLE memories (
  id BIGSERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  tags TEXT NOT NULL DEFAULT '',
  user_id UUID DEFAULT auth.uid() REFERENCES auth.users,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 创建附件元数据表
CREATE TABLE attachments (
  id BIGSERIAL PRIMARY KEY,
  memory_id BIGINT REFERENCES memories(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 创建 Storage 桶（存放附件文件）
INSERT INTO storage.buckets (id, name, public)
VALUES ('attachments', 'attachments', true)
ON CONFLICT (id) DO NOTHING;

-- 4. 配置 RLS + 用户数据隔离
ALTER TABLE memories ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_select_memories" ON memories;
CREATE POLICY "user_select_memories" ON memories
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "user_insert_memories" ON memories;
CREATE POLICY "user_insert_memories" ON memories
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "user_select_attachments" ON attachments;
CREATE POLICY "user_select_attachments" ON attachments
  FOR SELECT USING (
    memory_id IN (SELECT id FROM memories WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS "user_insert_attachments" ON attachments;
CREATE POLICY "user_insert_attachments" ON attachments
  FOR INSERT WITH CHECK (
    memory_id IN (SELECT id FROM memories WHERE user_id = auth.uid())
  );

-- Storage 权限
CREATE POLICY "storage_select" ON storage.objects
  FOR SELECT USING (bucket_id = 'attachments');

CREATE POLICY "storage_insert" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'attachments' AND auth.uid() IS NOT NULL);
