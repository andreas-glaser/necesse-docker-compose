PROJECT := necesse-docker-compose
DIST_DIR := dist
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo 0.1.0)

.PHONY: package clean

package: clean
	@echo "Packaging $(PROJECT) $(VERSION)"
	@mkdir -p $(DIST_DIR)/$(PROJECT)
	@cp Dockerfile docker-compose.yml entrypoint.sh README.md LICENSE .env.example $(DIST_DIR)/$(PROJECT)
	@cp -r .github $(DIST_DIR)/$(PROJECT)/.github
	@tar -czf $(DIST_DIR)/$(PROJECT)-$(VERSION).tar.gz -C $(DIST_DIR) $(PROJECT)
	@echo "Created $(DIST_DIR)/$(PROJECT)-$(VERSION).tar.gz"

clean:
	@rm -rf $(DIST_DIR)
