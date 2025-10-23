.PHONY: help start stop restart logs init-db test backup clean

help: ## 显示帮助信息
	@echo "T恤设计生成器 - 可用命令:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## 启动所有服务
	@./scripts/start.sh

stop: ## 停止所有服务
	@./scripts/stop.sh

restart: stop start ## 重启所有服务

logs: ## 查看 n8n 日志
	@docker-compose logs -f n8n

init-db: ## 初始化数据库
	@./scripts/init-database.sh

test: ## 测试工作流
	@./scripts/test-workflow.sh

backup: ## 创建备份
	@./scripts/backup.sh

clean: ## 清理所有数据（危险操作！）
	@echo "警告: 这将删除所有数据！"
	@read -p "确定要继续吗? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		rm -rf data/output/* data/uploads/*; \
		echo "清理完成"; \
	fi

status: ## 查看服务状态
	@docker-compose ps

shell-db: ## 连接到数据库
	@docker exec -it tshirt-design-db psql -U n8n -d n8n

shell-n8n: ## 进入 n8n 容器
	@docker exec -it tshirt-design-n8n /bin/sh

install: ## 安装依赖并启动
	@echo "检查 Docker..."
	@which docker > /dev/null || (echo "请先安装 Docker" && exit 1)
	@echo "检查 Docker Compose..."
	@which docker-compose > /dev/null || (echo "请先安装 Docker Compose" && exit 1)
	@echo "创建 .env 文件..."
	@test -f .env || cp .env.example .env
	@echo "完成！请编辑 .env 文件并运行 'make start'"
