# =============================================================================
# TLA+ / PlusCal Makefile for Uni-temporal Data Model
# =============================================================================

# 変数定義
TLA_TOOLS = /Applications/TLA+ Toolbox.app/Contents/Eclipse/tla2tools.jar
MODEL_FILE = uni_temporal_model.tla
CONFIG_FILE = uni_temporal_model.cfg
OLD_MODEL_FILE = tick_uni_temporal_model.tla
OLD_CONFIG_FILE = tick_uni_temporal_model.cfg

# デフォルトターゲット
.PHONY: all
all: check

# PlusCal翻訳を実行
.PHONY: trans
trans:
	@echo "🔄 Running PlusCal translation for Uni-temporal Model..."
	java -cp "$(TLA_TOOLS)" pcal.trans $(MODEL_FILE)
	@echo "✅ PlusCal translation completed"

# モデル検査を実行
.PHONY: check
check: trans
	@echo "🔍 Running TLA+ model checking for Uni-temporal Model..."
	@java -jar "$(TLA_TOOLS)" -config $(CONFIG_FILE) $(MODEL_FILE); \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		echo "✅ Uni-temporal model checking completed successfully"; \
	elif [ $$EXIT_CODE -eq 12 ]; then \
		echo "❌ Uni-temporal model checking found invariant violation"; \
	elif [ $$EXIT_CODE -eq 76 ]; then \
		echo "✅ Uni-temporal model checking completed (normal termination)"; \
	else \
		echo "⚠️  Uni-temporal model checking completed with exit code $$EXIT_CODE"; \
	fi

# 旧モデルでのモデル検査（互換性のため）
.PHONY: check-old
check-old:
	@echo "🔍 Running TLA+ model checking for old model..."
	@java -jar "$(TLA_TOOLS)" -config $(OLD_CONFIG_FILE) $(OLD_MODEL_FILE); \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		echo "✅ Old model checking completed successfully"; \
	elif [ $$EXIT_CODE -eq 12 ]; then \
		echo "❌ Old model checking found invariant violation"; \
	elif [ $$EXIT_CODE -eq 76 ]; then \
		echo "✅ Old model checking completed (normal termination)"; \
	else \
		echo "⚠️  Old model checking completed with exit code $$EXIT_CODE"; \
	fi

# モデル検査のみ実行（翻訳なし）
.PHONY: check-only
check-only:
	@echo "🔍 Running TLA+ model checking (without translation)..."
	@java -jar "$(TLA_TOOLS)" -config $(CONFIG_FILE) $(MODEL_FILE); \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		echo "✅ Model checking completed successfully"; \
	elif [ $$EXIT_CODE -eq 12 ]; then \
		echo "❌ Model checking found invariant violation"; \
	elif [ $$EXIT_CODE -eq 76 ]; then \
		echo "✅ Model checking completed (normal termination)"; \
	else \
		echo "⚠️  Model checking completed with exit code $$EXIT_CODE"; \
	fi

# 構文チェックのみ
.PHONY: syntax
syntax:
	@echo "📝 Checking TLA+ syntax for Uni-temporal Model..."
	java -cp "$(TLA_TOOLS)" tla2sany.SANY $(MODEL_FILE)
	@echo "✅ Syntax check completed"

# クリーンアップ（バックアップファイルを削除）
.PHONY: clean
clean:
	@echo "🧹 Cleaning up backup files..."
	rm -f *.bak
	@echo "✅ Cleanup completed"

# ヘルプ表示
.PHONY: help
help:
	@echo "📚 Available commands for Uni-temporal Data Model:"
	@echo "  make all       - Run PlusCal translation and model checking"
	@echo "  make trans     - Run PlusCal translation only"
	@echo "  make check     - Run PlusCal translation and model checking"
	@echo "  make check-old - Run model checking for old model (compatibility)"
	@echo "  make check-only- Run model checking only (without translation)"
	@echo "  make syntax    - Check TLA+ syntax only"
	@echo "  make clean     - Remove backup files"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "📋 Exit codes:"
	@echo "  0  - Success"
	@echo "  12 - Invariant violation found"
	@echo "  76 - Normal termination"
	@echo "  150- Parse/semantic error"
	@echo ""
	@echo "📁 Files:"
	@echo "  New model: $(MODEL_FILE)"
	@echo "  Old model: $(OLD_MODEL_FILE)"

# 詳細なモデル検査（デバッグ用）
.PHONY: check-verbose
check-verbose: trans
	@echo "🔍 Running TLA+ model checking (verbose mode)..."
	@java -jar "$(TLA_TOOLS)" -config $(CONFIG_FILE) $(MODEL_FILE) -verbose; \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		echo "✅ Verbose model checking completed successfully"; \
	elif [ $$EXIT_CODE -eq 12 ]; then \
		echo "❌ Model checking found invariant violation"; \
	elif [ $$EXIT_CODE -eq 76 ]; then \
		echo "✅ Verbose model checking completed (normal termination)"; \
	else \
		echo "⚠️  Verbose model checking completed with exit code $$EXIT_CODE"; \
	fi

# 高速モデル検査（並列実行）
.PHONY: check-fast
check-fast: trans
	@echo "🚀 Running TLA+ model checking (fast mode)..."
	@java -jar "$(TLA_TOOLS)" -config $(CONFIG_FILE) $(MODEL_FILE) -workers auto; \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then \
		echo "✅ Fast model checking completed successfully"; \
	elif [ $$EXIT_CODE -eq 12 ]; then \
		echo "❌ Model checking found invariant violation"; \
	elif [ $$EXIT_CODE -eq 76 ]; then \
		echo "✅ Fast model checking completed (normal termination)"; \
	else \
		echo "⚠️  Fast model checking completed with exit code $$EXIT_CODE"; \
	fi
