class RequestResultEntity{
  bool isSuccess = false;
  int retListSize = 0;
  bool isLastPage = false; // 是否最后一页

  RequestResultEntity(this.isSuccess, this.retListSize, this.isLastPage);
}