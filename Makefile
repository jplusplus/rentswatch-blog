install:
	gem install bundler jekyll

run:
	bundle exec jekyll serve --baseurl ''

publish:
	bundle exec jekyll build
	git checkout gh-pages
	git merge --no-ff master
	git push origin gh-pages
