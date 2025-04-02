def bubble(arr):
	arr_len = len(arr)
	for i in range(arr_len):
		for j in range(arr_len-1-i):
			if arr[j] > arr[j+1]:
				arr[j], arr[j+1] = arr[j+1], arr[j]
			
	return arr

def binary_s(arr, target):
	left, right = 0, len(arr)
	
	while right >= left:
		mid = (left + right)//2
		
		if arr[mid] == target:
			return mid
		elif arr[mid] < target:
			left = mid + 1
		else:
			right = mid - 1
	return - 1


def main():
	numbers = []
	print('arrey: ')
	while True:
		resp = input('>')
		if resp != "":
			num = int(resp)
			numbers.append(num)
		else:
			break
	print(numbers)
	print(bubble(numbers))
	target = int(input(f'target: '))
	print(binary_s(numbers, target))
	

if __name__ == "__main__":
	main()
