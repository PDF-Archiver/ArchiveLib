<div align="center">
<a href="https://geo.itunes.apple.com/us/app/pdf-archiver/id1352719750?mt=12&app=apps" target="itunes_store">
  <img src="assets/AppIcon.svg" width="200px">
</a>
<br>
<br>
<a href="https://geo.itunes.apple.com/us/app/pdf-archiver/id1352719750?mt=12&app=apps">
<img src="https://linkmaker.itunes.apple.com/en-us/badge-lrg.svg?releaseDate=2018-02-28T00:00:00Z&kind=desktopapp&bubble=macos_apps" width="165px">
</a>
<br>
<a href="https://travis-ci.org/PDF-Archiver/ArchiveLib">
<img src="https://travis-ci.org/PDF-Archiver/ArchiveLib.svg?branch=develop">
</a>
<a href="https://codecov.io/gh/PDF-Archiver/ArchiveLib">
<img src="https://codecov.io/gh/PDF-Archiver/ArchiveLib/branch/develop/graph/badge.svg">
</a>
<a href="https://codeclimate.com/github/PDF-Archiver/ArchiveLib/maintainability"><img src="https://api.codeclimate.com/v1/badges/91e16ceb1e5de7fb8703/maintainability" /></a>
</div>


# ArchiveLib

ArchiveLib is the backbone and is used in the following apps:
* **macOS:** [PDF Archiver](https://geo.itunes.apple.com/us/app/pdf-archiver/id1352719750?mt=12&app=apps)
* **iOS:** [PDF Archive Viewer](https://itunes.apple.com/app/apple-store/id1433801905?pt=118993774&ct=GitHub&mt=8)


## :scroll: Convention

* **Date:** `yyyy-mm-dd` Date of the document content.
* **Description:** `--ikea-tradfri-gateway` Meaningful description of the document.
* **Tags:** `__bill_ikea_iot` Tags which will help you to find the document in your archive.
Capital letters, spaces and language specific characters (such as `ä, ö, ü, ß`) will be removed to maximize the filesystem compatibility.

Your archive will look like this:
```
.
└── Archive
    ├── 2017
    │   ├── 2017-05-12--apple-macbook__apple_bill.pdf
    │   └── 2017-01-02--this-is-a-document__bill_vacation.pdf
    └── 2018
        ├── 2018-04-30--this-might-be-important__work_travel.pdf
        ├── 2018-05-26--parov-stelar__concert_ticket.pdf
        └── 2018-12-01--master-thesis__finally_longterm_university.pdf
```

This structure is independent from your OS and filesystem and makes it very easy to search files ...
* ... by tag via a searchterm like: `_tagname`, starting with `_`
* ... by description via a searchterm like: `-descriptionword`, starting with `-`
* ... by tag or description via a searchterm like: `searchword`,  starting with the term
* ... and even the file content: have a look at the [Pro Tips](#pro-tips)!
