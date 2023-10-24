.PHONY: deploy
deploy:
	@echo "====> deploying to github"
	/bin/rm -rf /tmp/book/
	git worktree add -f /tmp/book gh-pages
	mdbook build
	/bin/rm -rf /tmp/book/*
	cp -rp book/* /tmp/book/
	cd /tmp/book && \
			git add -A && \
			git commit -m "deployed new book" && \
			git push origin gh-pages

